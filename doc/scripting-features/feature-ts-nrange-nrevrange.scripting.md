# Feature: TS.NRANGE / TS.NREVRANGE support

## Goal

`RsRedisEndpoint` supports `TS.NRANGE` and `TS.NREVRANGE` (Redis 8.10+) via:

- `tsNRangeBy: rangeBlock keys: keysCollection`
- `tsNRangeBy: rangeBlock keys: keysCollection using: optionsBlock`
- `tsNRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock`
- `tsNRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock using: optionsBlock`
- the same four overloads as `tsNRevRangeBy:keys:...` for `TS.NREVRANGE`, sharing implementation with NRANGE (no duplicated command-building/parsing logic).

Unlike `TS.MRANGE` (which selects keys via `FILTER` and groups results by key), `TS.NRANGE`/`TS.NREVRANGE` take an explicit ordered key list and group results **by timestamp**. Results are returned as a collection of `RsTsNRangeRow` (`timestamp`/`values`), all covered by passing tests.

## Orchestration Shape

4 sequential steps, all via `claude`: implement TS.NRANGE (TDD) → implement TS.NREVRANGE (TDD, reuse) → run full TimeSeries test suite → lint & style review.

## Working Directory

`/home/mumez/git/RediStick` (existing checked-out RediStick repo, current branch `feature/ts-support_v810_3`).

## Design Notes (from prior analysis, verified against the official Redis docs since these are new 8.10 commands — implementers should follow this, not redesign it)

### Command grammar (verified via redis.io/docs, both commands byte-identical except direction)

```
TS.NRANGE numkeys key [key ...] fromTimestamp toTimestamp [LATEST]
  [FILTER_BY_TS ts [ts ...]] [FILTER_BY_VALUE min max] [COUNT count]
  [[ALIGN align] AGGREGATION aggregators [aggregators ...] bucketDuration
  [BUCKETTIMESTAMP <start | - | end | + | mid | ~>] [EMPTY]]
```

`TS.NREVRANGE` has the identical grammar; it only reverses timestamp order (highest first) and `COUNT` keeps the highest timestamps instead of the lowest.

Key differences from the already-implemented `TS.MRANGE`/`TS.MREVRANGE` (`src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`) that this design leans on:
- Keys are an **explicit ordered list** (`numkeys key...`), not a `FILTER` expression — no `RsTsFilterBuilder` involved. Duplicate keys are legal.
- No `WITHLABELS`/`SELECTED_LABELS`/`GROUPBY` — options are exactly `LATEST`/`FILTER_BY_TS`/`FILTER_BY_VALUE`/`COUNT`, identical in shape/ordering to the single-key `RsTsRangeOptions` already used by `TS.RANGE`/`TS.REVRANGE` — **reuse `RsTsRangeOptions` unchanged**, do not create a new options class for this part.
- `AGGREGATION` here takes **one aggregator-list per key** (each a single token or comma-joined list like `avg,max`), followed by ONE shared `bucketDuration` — new shape vs. the existing single-aggregator-list `RsTsAggregation`. `ALIGN`/`BUCKETTIMESTAMP`/`EMPTY` still wrap it exactly like `RsTsAggregationOptions` already does for `TS.RANGE`/`TS.MRANGE` — reuse `RsTsAggregationOptions` unchanged by injecting a new per-key aggregation object into its existing `aggregation:` setter (its `asArray` just calls `self aggregation asArray`, so any object responding to `asArray` works — no changes needed to `RsTsAggregationOptions` itself).
- Reply is **grouped by timestamp**, not by key: `{ timestamp. flatValuesArray }` per row, ordered by increasing timestamp (NRANGE) or decreasing timestamp (NREVRANGE). `flatValuesArray` is one value per key (or per key's aggregator, in AGGREGATION mode), in key/aggregator order. Missing values arrive as an unparseable string on the wire — do NOT add special NaN handling, just reuse the existing `tsParseValue:` helper unchanged (it already falls back to returning the raw string via `NumberParser parse:onError:`, this package's existing convention for unparseable values).

### Existing reference points in `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`

- `tsExecuteRange:cmdName:key:rangeBy:aggregationBy:using:`, `tsRangeFrom:`, `tsParseRangeSamples:`, `tsParseValue:` — the single-key TS.RANGE/TS.REVRANGE implementation.
- `tsMRangeBy:filterBy:...`, `tsExecuteMRange:cmdName:rangeBy:filterBy:aggregationBy:groupBy:using:`, `tsMRangeArgsFor:cmdName:range:options:aggOptions:filterBuilder:groupBy:`, `tsParseMRangeResult:groupBy:`, `tsParseRangeRow:` — the already-implemented TS.MRANGE/TS.MREVRANGE, which TS.NRANGE parallels in *shape* (one private executor, `cmdName` swapped for the REV variant) but differs in key selection (explicit list, not FILTER) and reply grouping (by timestamp, not by key).
- `src/RediStick-TimeSeries/RsTsRangeOptions.class.st` — reuse unchanged for NRANGE's LATEST/FILTER_BY_TS/FILTER_BY_VALUE/COUNT options.
- `src/RediStick-TimeSeries/RsTsAggregation.class.st` — existing single-command-wide aggregator-list builder (`avg`/`sum`/`min`/`max`/etc. methods appending token strings to `aggregators`, plus `bucketDuration`, plus `asArray`).
- `src/RediStick-TimeSeries/RsTsAggregationOptions.class.st` — reuse unchanged (ALIGN/AGGREGATION/BUCKETTIMESTAMP/EMPTY wrapper); its `aggregation:` setter accepts any object responding to `asArray`.
- `src/RediStick-TimeSeries/RsTsRangeValue.class.st` — simple accessor-class shape to mirror for the new row class.

### Refactor: `RsTsAggregation >> aggregatorsString`

Factor the existing `($, join: self aggregators)` logic out of `RsTsAggregation>>asArray` into a new method `aggregatorsString` (keep the `aggregators notEmpty` validation, signalling the same `Error` as today if empty). Have `asArray` call `self aggregatorsString` instead of duplicating the join logic. Pure refactor — behavior of `asArray` must be unchanged and the existing `RsTsAggregationTest` must keep passing without modification (add one new test case for `aggregatorsString` itself).

### New class: `RsTsNAggregation` (in `src/RediStick-TimeSeries/`)

Instance vars: `perKeyAggregators` (`OrderedCollection` of `RsTsAggregation` instances, one per key, in key order), `bucketDuration`. `initialize` sets `perKeyAggregators := OrderedCollection new`.

- `bucketDuration:` / `bucketDuration` — plain accessors.
- `forKey: aBlock` — creates `RsTsAggregation new`, evaluates `aBlock value: thatAggregation` (so callers invoke `avg`/`sum`/`max`/etc., or several of those for a comma-joined multi-aggregator key), appends it to `perKeyAggregators`, and answers it. Called once per key, in the same order as the `keys` collection passed to the NRANGE method.
- `asArray` — signals `Error` if `perKeyAggregators` is empty ("At least one key aggregation must be provided", mirroring `RsTsAggregation>>asArray`'s validation style) or if `bucketDuration` is nil ("bucketDuration must be set"); otherwise answers `{ 'AGGREGATION' }, (self perKeyAggregators collect: [ :agg | agg aggregatorsString ]), { self bucketDuration }`.

### New class: `RsTsNRangeRow` (in `src/RediStick-TimeSeries/`)

Instance vars `timestamp`, `values` (plain accessor-class, mirror `RsTsRangeValue.class.st`'s shape closely — read it first). Class-side `timestamp:values:`. `values` is an `Array` of parsed per-key (or per-key-aggregator) values, in the same order as the `keys`/aggregation-block calls that produced them.

### Endpoint method shape

Four public entry points per command (mirroring `tsRange:rangeBy:using:` / `tsRange:rangeBy:aggregationBy:using:`'s pattern of delegating to one private executor, but taking an explicit `keys` collection instead of a single `key`):

```
tsNRangeBy: rangeBlock keys: keysCollection
tsNRangeBy: rangeBlock keys: keysCollection using: optionsBlock
tsNRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock
tsNRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock using: optionsBlock
```

all delegating to one private `tsExecuteNRange: cmdName keys: keysCollection rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock` that:
1. Signals `Error` ("At least one key is required", same style as `tsExecuteMRange:`'s filter-required check) if `keysCollection isEmpty`.
2. Builds the range via `self tsRangeFrom: (rangeBlock value: RsTsRange)` (unchanged helper).
3. Builds `RsTsRangeOptions` from `optionsBlock` if given (reused unchanged from TS.RANGE).
4. Builds `RsTsAggregationOptions` + a fresh `RsTsNAggregation` from `aggregationBlock` if given: `aggOptions := RsTsAggregationOptions new. nAgg := RsTsNAggregation new. aggOptions aggregation: nAgg. aggregationBlock cull: nAgg cull: aggOptions` (mirrors the `cull:cull:` calling convention already used for TS.RANGE/TS.MRANGE's `aggregationBy:` block, with `RsTsNAggregation` substituted for the default `RsTsAggregation`).
5. Assembles args in command-grammar order: `cmdName`, `keysCollection size`, `keysCollection` (flattened), range `asArray`, options `asArray` (if given), aggOptions `asArray` (if given — `RsTsAggregationOptions>>asArray` already emits ALIGN before AGGREGATION and BUCKETTIMESTAMP/EMPTY after, matching this command's grammar exactly).
6. Sends via `self unifiedCommand: args`.
7. Parses via a new private `tsParseNRangeResult:`: `rawResult ifNil: [ ^ #() ]`; each row is `{ timestamp. flatValuesArray }` → `RsTsNRangeRow timestamp: row first values: (row second collect: [ :v | self tsParseValue: v ])`.

The `TS.NREVRANGE` public methods (added in the second implementation step below) must call the *same* private executor with `cmdName: 'TS.NREVRANGE'` — no separate arg-building or parsing code.

### Tests to add (in `src/RediStick-TimeSeries-Tests/`)

- `RsTsNAggregationTest` (plain `TestCase`, mirror `RsTsAggregationTest`'s structure): `forKey:` building per-key aggregator lists (single and comma-joined multi-aggregator), `asArray` shape/ordering, missing-perKeyAggregators-signals-Error, missing-bucketDuration-signals-Error.
- `RsTsAggregationTest` — add (don't replace) a case covering the new `aggregatorsString` method directly; confirm the existing `asArray` tests still pass after the refactor.
- `RsTsNRangeTest` (extends `RsRedisTestCase`, mirror `RsTsMRangeTest.class.st`'s structure/style closely — same `tsCreate:using:`/`tsAdd:timestamp:value:` setup, use `RsRedisTestCase dbIndex`): a plain multi-key case (no aggregation) asserting rows come back grouped by timestamp with one value per key in key order, including a timestamp where one key has no sample; an `aggregationBy:` case with per-key aggregators (including one key with a comma-joined multi-aggregator) over a shared bucketDuration; the "no keys signals Error" case; a "no matching series returns `#()`" case.
- `RsTsNRevRangeTest` (extends `RsRedisTestCase`, mirror `RsTsMRevRangeTest`'s minimal-but-sufficient style): confirm `TS.NREVRANGE` reaches Redis correctly and rows come back in descending timestamp order compared to `TS.NRANGE` for the same data — no need to duplicate every NRANGE case.

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement TS.NRANGE (TDD)'.
            t prompt: 'In the RediStick repo (Pharo Smalltalk Redis client, Tonel format), implement TS.NRANGE support in the RediStick-TimeSeries package, following Test-Driven Development: write failing tests first, then implement, then get them green.

Read these existing files first to match conventions exactly before writing anything:
- src/RediStick-TimeSeries/RsRedisEndpoint.extension.st (methods: tsExecuteRange:cmdName:key:rangeBy:aggregationBy:using:, tsRangeFrom:, tsParseRangeSamples:, tsParseValue:, tsMRangeBy:filterBy:, tsExecuteMRange:cmdName:rangeBy:filterBy:aggregationBy:groupBy:using:, tsMRangeArgsFor:cmdName:range:options:aggOptions:filterBuilder:groupBy:, tsParseMRangeResult:groupBy:, tsParseRangeRow:)
- src/RediStick-TimeSeries/RsTsRangeOptions.class.st
- src/RediStick-TimeSeries/RsTsAggregation.class.st
- src/RediStick-TimeSeries/RsTsAggregationOptions.class.st
- src/RediStick-TimeSeries/RsTsRangeValue.class.st
- src/RediStick-TimeSeries-Tests/RsTsMRangeTest.class.st and RsTsRangeOptionsTest.class.st and RsTsAggregationTest.class.st and RsTsAggregationOptionsTest.class.st (test style/structure templates)
- CLAUDE.md''s Development and Testing Workflow section for the smalltalk-interop/smalltalk-validator MCP workflow (import_package after every .st edit, validate_tonel_smalltalk_from_file before importing, run_class_test / run_package_test to check)

TS.NRANGE / TS.NREVRANGE are new in Redis 8.10 and query an EXPLICIT list of keys (not a FILTER expression like TS.MRANGE), grouping results BY TIMESTAMP instead of by key. Verified command grammar:
TS.NRANGE numkeys key [key ...] fromTimestamp toTimestamp [LATEST] [FILTER_BY_TS ts [ts ...]] [FILTER_BY_VALUE min max] [COUNT count] [[ALIGN align] AGGREGATION aggregators [aggregators ...] bucketDuration [BUCKETTIMESTAMP <start|-|end|+|mid|~>] [EMPTY]]
Options (LATEST/FILTER_BY_TS/FILTER_BY_VALUE/COUNT) are identical in shape/order to RsTsRangeOptions (used by TS.RANGE) — reuse RsTsRangeOptions UNCHANGED, do not create a new options class for this part. AGGREGATION here takes ONE aggregator-list per key (a single token or comma-joined list like ''avg,max''), followed by ONE shared bucketDuration — this is genuinely new vs. the single-aggregator-list RsTsAggregation. ALIGN/BUCKETTIMESTAMP/EMPTY still wrap it exactly like RsTsAggregationOptions already does — reuse RsTsAggregationOptions UNCHANGED (its aggregation: setter and asArray work with any object responding to asArray). Reply rows are { timestamp. flatValuesArray } ordered by increasing timestamp, one value per key (or per key-aggregator) in key order; missing values are an unparseable string on the wire — do NOT add special NaN handling, just reuse tsParseValue: unchanged (it already falls back to the raw string via NumberParser parse:onError:).

Build exactly this design (do not redesign it):

1. Refactor RsTsAggregation (src/RediStick-TimeSeries/RsTsAggregation.class.st): factor the existing ($, join: self aggregators) logic out of asArray into a new method aggregatorsString (keep the "aggregators notEmpty" validation, same Error as today if empty). asArray must call self aggregatorsString instead of duplicating the join logic. Pure refactor — asArray''s behavior and the existing RsTsAggregationTest must be unchanged; add one new test case for aggregatorsString itself in RsTsAggregationTest.class.st.

2. New class RsTsNAggregation (src/RediStick-TimeSeries/RsTsNAggregation.class.st): instance vars perKeyAggregators (OrderedCollection of RsTsAggregation, one per key, in key order), bucketDuration. initialize sets perKeyAggregators := OrderedCollection new. bucketDuration:/bucketDuration accessors. forKey: aBlock creates RsTsAggregation new, evaluates aBlock value: thatAggregation, appends it to perKeyAggregators, answers it. asArray signals Error if perKeyAggregators is empty (''At least one key aggregation must be provided'') or bucketDuration is nil (''bucketDuration must be set''); otherwise answers { ''AGGREGATION'' }, (self perKeyAggregators collect: [ :agg | agg aggregatorsString ]), { self bucketDuration }.

3. New class RsTsNRangeRow (src/RediStick-TimeSeries/RsTsNRangeRow.class.st): instance vars timestamp, values. Class-side timestamp:values:. Plain accessors, mirroring RsTsRangeValue.class.st''s shape (printOn:, isRsTsNRangeRow-style testing method optional but nice to mirror if RsTsRangeValue has one).

4. In RsRedisEndpoint.extension.st add four public methods:
   tsNRangeBy: rangeBlock keys: keysCollection
   tsNRangeBy: rangeBlock keys: keysCollection using: optionsBlock
   tsNRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock
   tsNRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock using: optionsBlock
   all delegating to one new private method:
   tsExecuteNRange: cmdName keys: keysCollection rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock
   which: signals Error (''At least one key is required'') if keysCollection isEmpty; builds the range via self tsRangeFrom: (rangeBlock value: RsTsRange); builds RsTsRangeOptions from optionsBlock if given; builds RsTsAggregationOptions + a fresh RsTsNAggregation from aggregationBlock if given (aggOptions := RsTsAggregationOptions new. nAgg := RsTsNAggregation new. aggOptions aggregation: nAgg. aggregationBlock cull: nAgg cull: aggOptions); assembles args in this exact order: cmdName, keysCollection size, keysCollection (flattened), range asArray, options asArray (if options), aggOptions asArray (if aggOptions); sends via self unifiedCommand: args; parses the result via a new private tsParseNRangeResult: helper.

   Call it with cmdName ''TS.NRANGE'' from the four tsNRangeBy:... methods (the TS.NREVRANGE methods come in the next step and must reuse this same private executor).

5. Parsing (tsParseNRangeResult:): rawResult ifNil: [ ^ #() ]. Each row is { timestamp. flatValuesArray } -> RsTsNRangeRow timestamp: row first values: (row second collect: [ :v | self tsParseValue: v ]).

Tests to write first (TDD) in src/RediStick-TimeSeries-Tests/:
- RsTsNAggregationTest (plain TestCase, mirror RsTsAggregationTest''s structure): forKey: building per-key aggregator lists (single and comma-joined multi-aggregator), asArray shape/ordering, missing-perKeyAggregators-signals-Error, missing-bucketDuration-signals-Error.
- RsTsNRangeTest (extends RsRedisTestCase, mirror RsTsMRangeTest.class.st''s structure and use RsRedisTestCase dbIndex like it does): a plain multi-key tsNRangeBy:keys: case asserting rows grouped by timestamp with one value per key in key order (including a timestamp where one key has no sample); an aggregationBy: case with per-key aggregators (including one key using a comma-joined multi-aggregator) over a shared bucketDuration; a "no keys signals Error" case; a "no matching series returns #()" case.

Follow CLAUDE.md''s workflow: validate each .st file with the smalltalk-validator MCP tool before importing, import both RediStick-TimeSeries and RediStick-TimeSeries-Tests via smalltalk-interop MCP after edits, and run the new test classes via run_class_test. Commit nothing yet (no git commits in this step) — just get the code written and the new tests green in the running image.'.
            t goal: 'RsTsNAggregationTest and RsTsNRangeTest all pass in the running Pharo image, and the existing RsTsAggregationTest still passes after the aggregatorsString refactor' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement TS.NREVRANGE (reuse TS.NRANGE executor)'.
            t prompt: 'Continuing the RediStick TimeSeries work from the previous step (TS.NRANGE is now implemented via a private RsRedisEndpoint>>tsExecuteNRange:keys:rangeBy:aggregationBy:using: executor), now add TS.NREVRANGE support with NO duplicated logic: it must call the exact same private executor, passing cmdName ''TS.NREVRANGE'' instead of ''TS.NRANGE''.

Add these four public methods to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st, mirroring the tsNRangeBy:... methods added previously and delegating to the same private tsExecuteNRange:keys:rangeBy:aggregationBy:using: helper:
   tsNRevRangeBy: rangeBlock keys: keysCollection
   tsNRevRangeBy: rangeBlock keys: keysCollection using: optionsBlock
   tsNRevRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock
   tsNRevRangeBy: rangeBlock keys: keysCollection aggregationBy: aggregationBlock using: optionsBlock

Write a new test class first (TDD), src/RediStick-TimeSeries-Tests/RsTsNRevRangeTest.class.st (extends RsRedisTestCase, mirror RsTsMRevRangeTest''s structure): at minimum, add several timestamped samples to two or more series, call tsNRevRangeBy:keys: and tsNRangeBy:keys: with the same range/keys, and assert the NREVRANGE result''s rows come back with timestamps in descending order (opposite of NRANGE''s ascending order) for the same underlying data — this is enough to prove TS.NREVRANGE is wired correctly through the shared executor; do not duplicate every TS.NRANGE test case.

Follow the same workflow as before: validate with smalltalk-validator, import both RediStick-TimeSeries and RediStick-TimeSeries-Tests via smalltalk-interop MCP, run the new test class via run_class_test. No git commits yet.'.
            t goal: 'RsTsNRevRangeTest passes in the running Pharo image' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Run full TimeSeries test suite'.
            t prompt: 'In the RediStick repo, re-import the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages via the smalltalk-interop MCP import_package tool (to be sure the running Pharo image reflects the latest .st files from the previous two steps), then run the full RediStick-TimeSeries-Tests package test suite via the smalltalk-interop MCP run_package_test tool (or run_class_test across every test class in that package, including the pre-existing RsTsTest, RsTsFilterTest, RsTsFilterBuilderTest, RsTsMAddTest, RsTsQueryIndexTest, RsTsQueryLabelsTest, RsTsRangeTest, RsTsRangeOptionsTest, RsTsValueTest, RsTsAggregationTest, RsTsAggregationOptionsTest, RsTsMGetOptionsTest, RsTsMGetTest, RsTsMRangeOptionsTest, RsTsGroupByTest, RsTsMRangeTest, RsTsMRevRangeTest, RsTsReadOptionsTest, RsTsSchemaOptionsTest, plus the new RsTsNAggregationTest, RsTsNRangeTest, RsTsNRevRangeTest). Report a plain-text pass/fail count per test class and flag any regressions in the pre-existing tests caused by the RsTsAggregation aggregatorsString refactor or the new TS.NRANGE/TS.NREVRANGE code. Do not fix anything yet if something fails — just report exactly what failed and why (error message / assertion) so the next step or a human can act on it.' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Lint and style review'.
            t prompt: 'Review all the .st files added or changed in the RediStick repo for the TS.NRANGE/TS.NREVRANGE feature (src/RediStick-TimeSeries/RsTsAggregation.class.st, RsTsNAggregation.class.st, RsTsNRangeRow.class.st, RsRedisEndpoint.extension.st, and src/RediStick-TimeSeries-Tests/RsTsAggregationTest.class.st, RsTsNAggregationTest.class.st, RsTsNRangeTest.class.st, RsTsNRevRangeTest.class.st). Consult the st-lint skill (or the smalltalk-validator MCP tools directly) against each changed Tonel file, and consult the smalltalk-developer skill''s style guide / best-practices section (method categorization, CRC-style class comments, Tonel syntax conventions). Fix whatever issues are found — lint warnings, missing or wrong method categories, missing class comments, style inconsistencies with the rest of the RediStick-TimeSeries package. After fixing, re-import the affected packages and re-run the previously-passing tests to confirm nothing broke from the cleanup. If any test regressed from the previous step''s report, fix the underlying cause here too.'.
            t goal: 'lint clean and style-guide issues fixed, with all RediStick-TimeSeries-Tests still passing' ]
    } agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'TS.NRANGE/TS.NREVRANGE orchestration done: ' , orc result ]
    onTimeout: [ :timeoutStep :ex | Transcript crShow: 'TS.NRANGE/TS.NREVRANGE orchestration timed out at: ' , timeoutStep printString ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:onTimeout:` runs the orchestration in the background and returns immediately — watch for the completion block's own report (e.g. via Transcript), the `onTimeout:` block's report if a step stalls, or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
