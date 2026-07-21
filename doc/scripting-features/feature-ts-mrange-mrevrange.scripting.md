# Feature: TS.MRANGE / TS.MREVRANGE support

## Goal

`RsRedisEndpoint` supports `TS.MRANGE` and `TS.MREVRANGE` via:

- `tsMRangeBy: rangeBlock filterBy: filterBlock`
- `tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: optionsBlock`
- `tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock`
- the same three overloads as `tsMRevRangeBy:filterBy:...` for `TS.MREVRANGE`, sharing implementation with MRANGE (no duplicated command-building/parsing logic).

Results are returned as a collection of `RsTsRangeValue` (no `groupBy:`) or `RsTsGroupedRangeValue` (with `groupBy:`), all covered by passing tests.

## Orchestration Shape

4 sequential steps, all via `claude`: implement TS.MRANGE (TDD) → implement TS.MREVRANGE (TDD, reuse) → run full TimeSeries test suite → lint & style review.

## Working Directory

`/home/mumez/git/RediStick` (existing checked-out RediStick repo, current branch `feature/time-series`).

## Design Notes (from prior analysis — implementers should follow this, not redesign it)

Existing reference points in `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`:
- `tsMGetFilterBy:filterBlock` / `tsMGetFilterBy:filterBlock using:optionsBlock` — filter-builder + options pattern to copy.
- `tsExecuteRange:cmdName key:rangeBy:aggregationBy:using:` and its helpers `tsRangeFrom:`, `tsRangeArgsFor:key:range:options:aggregation:aggOptions:`, `tsParseRangeSamples:` — the single-key TS.RANGE/TS.REVRANGE implementation that MRANGE parallels, but MRANGE has no single `key` (it uses FILTER instead) and returns one row per matched key.
- `tsQueryIndexFilterBy:` and `tsMGetFilterBy:...` both use `RsTsFilterBuilder` (see `RsTsFilterBuilder.class.st`, `RsTsFilter.class.st`) for FILTER expressions — reuse it unchanged for MRANGE/MREVRANGE's required `FILTER filterExpr...` clause (signal `Error` if no filters given, exactly like `tsMGetFilterBy:` and `tsQueryIndexFilterBy:` already do).
- `RsTsAggregation` (aggregator tokens + bucketDuration) and `RsTsAggregationOptions` (`alignArray`, `tailArray` for ALIGN/BUCKETTIMESTAMP/EMPTY) are already shared by TS.RANGE; reuse them unchanged for the `aggregationBy:` block, called the same way: `aggregationBlock cull: aggregation cull: aggOptions`.

### New option class: `RsTsMRangeOptions` (in `src/RediStick-TimeSeries/`)

Instance vars: `latest`, `filterByTs`, `filterByValueMin`, `filterByValueMax`, `withLabels`, `selectedLabels`, `count`. This merges `RsTsRangeOptions` (LATEST/FILTER_BY_TS/FILTER_BY_VALUE/COUNT) with `RsTsMGetOptions` (WITHLABELS/SELECTED_LABELS) since TS.MRANGE accepts both groups. `initialize` sets `latest := false`, `withLabels := false`.

`asArray` must emit tokens in this exact order (this is the real TS.MRANGE command grammar — do not reorder):
1. `LATEST` if set
2. `FILTER_BY_TS`, ts... if set (normalize each timestamp via `RsTsRange normalizeTimestamp:`, same as `RsTsRangeOptions>>filterByTs:` does)
3. `FILTER_BY_VALUE`, min, max if both min and max are set
4. `SELECTED_LABELS`, label... if `selectedLabels` is set; else `WITHLABELS` if `withLabels` is set
5. `COUNT`, count if set

Provide the same accessor shapes as `RsTsRangeOptions` (`filterByValueMin:max:`, `filterByTs:`, `count:`) and `RsTsMGetOptions` (`withLabels`, `selectedLabels:`) — read both classes first so method names match existing conventions exactly (e.g. the "set to true" idiom used by `latest`/`withLabels`/`empty` elsewhere in this package).

### New class: `RsTsGroupBy` (in `src/RediStick-TimeSeries/`)

Instance vars: `label`, `reducer`. Accessors `label:`/`label`, `reduce:`/`reducer` (setter is `reduce:` to match the `GROUPBY label REDUCE reducer` command shape; reducer is a single token string like `'sum'`, `'avg'`, `'min'`, `'max'`). `asArray` returns `{ 'GROUPBY'. self label. 'REDUCE'. self reducer }`, signalling `Error` if either `label` or `reducer` is nil (mirror `RsTsAggregation>>asArray`'s validation style).

The `groupBy:` block parameter passed to `tsMRangeBy:...groupBy:...using:` is called as `groupingBlock value: aRsTsGroupBy` (single-arg block, unlike the two-arg `cull:cull:` used for aggregation, since GROUPBY only needs label+reducer).

### New value classes (in `src/RediStick-TimeSeries/`)

`RsTsRangeValue` — instance vars `key`, `labels`, `values`; class-side `key:labels:values:`; plain accessors (mirror the simple `RsTsValue.class.st` shape already in this package — read it first).

`RsTsGroupedRangeValue` — instance vars `key`, `labels`, `groupByLabel`, `reducer`, `sourceKeys`, `values`; class-side `key:labels:groupByLabel:reducer:sourceKeys:values:`; plain accessors. `groupByLabel` holds an `Association` (`label -> value`, or `label -> nil` if the label is absent from the row). `sourceKeys` is an `Array` of key-name strings (parsed by splitting the raw `__source__` value on `,` — use `substrings: ','`, not `tokenize:`).

### Parsing the raw MRANGE/MREVRANGE reply

Each row from Redis is `{ theKeyOrGroupString. labelPairs. samples }` where `samples` is an array of `{ timestamp. value }` pairs — reuse `tsParseRangeSamples:` unchanged on `samples` for both grouped and ungrouped rows (it already does exactly this timestamp/value parsing for TS.RANGE). Reuse `tsLabelsDictionaryFrom:` unchanged to turn `labelPairs` into a `Dictionary`.

- **Without `groupBy:`**: row is `{ key. labelPairs. samples }` (same shape as `tsMGetFilterBy:`'s per-row MGET reply, just with a samples array instead of one sample) → build `RsTsRangeValue key: row first labels: (self tsLabelsDictionaryFrom: row second) values: (self tsParseRangeSamples: row third)`.
- **With `groupBy:`**: row's first element is the group value string (e.g. `'region=west'`); `labelPairs` additionally contains two pseudo-label entries `__reducer__` (the reducer token, e.g. `'sum'`) and `__source__` (comma-joined source key names) alongside the real groupby label entry. Build the `Dictionary` the same way via `tsLabelsDictionaryFrom:`, then read `groupByLabel` as `(the groupBy's label) -> (dict at: thatLabel ifAbsent: [nil])`, `reducer` as `dict at: '__reducer__' ifAbsent: [nil]`, `sourceKeys` as `(dict at: '__source__' ifAbsent: ['']) substrings: ','` (as an `Array`).
- A private dispatch helper (e.g. `tsParseMRangeResult:groupBy:`) should pick the grouped vs ungrouped row parser based on whether a `RsTsGroupBy` was supplied — `nil` result (no matching series) returns `#()`, matching `tsParseMGetResult:`'s style.

### Endpoint method shape

Three public entry points per command (mirroring `tsRange:rangeBy:using:` / `tsRange:rangeBy:aggregationBy:using:`'s pattern of delegating to one private executor):

```
tsMRangeBy: rangeBlock filterBy: filterBlock
tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: optionsBlock
tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock
```

all delegating to one private `tsExecuteMRange: cmdName rangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock` that:
1. builds the range via `self tsRangeFrom: (rangeBlock value: RsTsRange)` (unchanged helper)
2. builds an `RsTsFilterBuilder`, evaluates `filterBlock`, signals `Error` if `builder filters` is empty (same message/style as `tsMGetFilterBy:`)
3. builds `RsTsMRangeOptions` from `optionsBlock` if given
4. builds `RsTsAggregation`/`RsTsAggregationOptions` from `aggregationBlock` if given (via `cull:cull:`, as `tsExecuteRange:` already does)
5. builds `RsTsGroupBy` from `groupingBlock` if given
6. assembles the full args array in command-grammar order: `cmdName`, range `asArray`, options `asArray`, aggOptions `alignArray`, aggregation `asArray`, aggOptions `tailArray`, `'FILTER'`, filter strings, then `groupBy asArray` if a group-by was given
7. sends via `self unifiedCommand: args`, then parses via the dispatch helper above

The MREVRANGE public methods (added in the second implementation step below) must call the *same* private executor with `cmdName: 'TS.MREVRANGE'` — no separate arg-building or parsing code.

### Tests to add (in `src/RediStick-TimeSeries-Tests/`)

- `RsTsMRangeOptionsTest` (plain `TestCase`, mirrors `RsTsAggregationOptionsTest`/style of `RsTsRangeOptions` — no existing standalone test class for `RsTsRangeOptions`/`RsTsMGetOptions`, so use `RsTsAggregationOptionsTest.class.st` as the structural template): cover LATEST, FILTER_BY_TS, FILTER_BY_VALUE, WITHLABELS vs SELECTED_LABELS precedence, COUNT, and combined ordering.
- `RsTsGroupByTest` (plain `TestCase`, mirror `RsTsAggregationTest`'s style): `asArray` shape and the "missing label/reducer signals Error" case.
- `RsTsMRangeTest` (extends `RsRedisTestCase`, mirror `RsTsMGetTest.class.st`'s structure/style closely — same kind of `tsCreate:using:`/`tsAdd:timestamp:value:` setup): cover a plain multi-key range (no aggregation/groupBy), an aggregation case, a `groupBy:` case asserting `RsTsGroupedRangeValue`'s `groupByLabel`/`reducer`/`sourceKeys`/`values`, the "no filters signals Error" case, and a "no matching series returns `#()`" case.
- `RsTsMRevRangeTest` (extends `RsRedisTestCase`, mirror `RsTsMRangeTest`): at minimum confirm the command reaches Redis correctly and results come back in reverse timestamp order compared to MRANGE for the same data — no need to duplicate every MRANGE case, just enough to prove `TS.MREVRANGE` is wired correctly through the shared executor.

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement TS.MRANGE (TDD)'.
            t prompt: 'In the RediStick repo (Pharo Smalltalk Redis client, Tonel format), implement TS.MRANGE support in the RediStick-TimeSeries package, following Test-Driven Development: write failing tests first, then implement, then get them green.

Read these existing files first to match conventions exactly before writing anything:
- src/RediStick-TimeSeries/RsRedisEndpoint.extension.st (methods: tsMGetFilterBy:, tsMGetFilterBy:using:, tsExecuteRange:cmdName:key:rangeBy:aggregationBy:using:, tsRangeFrom:, tsRangeArgsFor:key:range:options:aggregation:aggOptions:, tsParseRangeSamples:, tsParseMGetResult:, tsValueFromMGetRow:, tsLabelsDictionaryFrom:, tsQueryIndexFilterBy:)
- src/RediStick-TimeSeries/RsTsRangeOptions.class.st
- src/RediStick-TimeSeries/RsTsMGetOptions.class.st
- src/RediStick-TimeSeries/RsTsFilterBuilder.class.st and RsTsFilter.class.st
- src/RediStick-TimeSeries/RsTsAggregation.class.st and RsTsAggregationOptions.class.st
- src/RediStick-TimeSeries/RsTsValue.class.st
- src/RediStick-TimeSeries-Tests/RsTsMGetTest.class.st and RsTsAggregationOptionsTest.class.st and RsTsAggregationTest.class.st (test style/structure templates)
- CLAUDE.md''s Development and Testing Workflow section for the smalltalk-interop/smalltalk-validator MCP workflow (import_package after every .st edit, validate_tonel_smalltalk_from_file before importing, run_class_test / run_package_test to check)

Build exactly this design (do not redesign it):

1. New class RsTsMRangeOptions (src/RediStick-TimeSeries/RsTsMRangeOptions.class.st): instance vars latest, filterByTs, filterByValueMin, filterByValueMax, withLabels, selectedLabels, count. initialize sets latest := false, withLabels := false. Provide accessors matching RsTsRangeOptions'' and RsTsMGetOptions'' method names/idioms (filterByTs:, filterByValueMin:max:, count:, count, withLabels, isWithLabels, selectedLabels:, selectedLabels, latest, isLatest). asArray must emit, in this exact order: LATEST (if set) -> FILTER_BY_TS ts... (if set, each timestamp normalized via RsTsRange normalizeTimestamp:) -> FILTER_BY_VALUE min max (if both min and max set) -> SELECTED_LABELS label... (if selectedLabels set) else WITHLABELS (if withLabels set) -> COUNT count (if set).

2. New class RsTsGroupBy (src/RediStick-TimeSeries/RsTsGroupBy.class.st): instance vars label, reducer. label:/label, reduce:/reducer accessors. asArray answers { ''GROUPBY''. self label. ''REDUCE''. self reducer }, signalling Error if label or reducer is nil (mirror RsTsAggregation>>asArray''s validation style).

3. New class RsTsRangeValue (src/RediStick-TimeSeries/RsTsRangeValue.class.st): instance vars key, labels, values. Class-side key:labels:values:. Plain accessors, mirroring RsTsValue.class.st''s shape.

4. New class RsTsGroupedRangeValue (src/RediStick-TimeSeries/RsTsGroupedRangeValue.class.st): instance vars key, labels, groupByLabel, reducer, sourceKeys, values. Class-side key:labels:groupByLabel:reducer:sourceKeys:values:. Plain accessors. groupByLabel is an Association (label -> value or label -> nil). sourceKeys is an Array of strings.

5. In RsRedisEndpoint.extension.st add three public methods:
   tsMRangeBy: rangeBlock filterBy: filterBlock
   tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: optionsBlock
   tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock
   all delegating to one new private method:
   tsExecuteMRange: cmdName rangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock
   which: builds the range via self tsRangeFrom: (rangeBlock value: RsTsRange); builds an RsTsFilterBuilder and evaluates filterBlock, signalling Error (same message as tsMGetFilterBy:''s "At least one filter expression is required") if builder filters is empty; builds RsTsMRangeOptions from optionsBlock if given; builds RsTsAggregation + RsTsAggregationOptions from aggregationBlock if given via cull:cull: (as tsExecuteRange: already does); builds RsTsGroupBy from groupingBlock (single-arg block: groupingBlock value: aRsTsGroupBy) if given; assembles args in this exact order: cmdName, range asArray, options asArray (if options), aggOptions alignArray (if aggOptions), aggregation asArray (if aggregation), aggOptions tailArray (if aggOptions), ''FILTER'', the filter strings, then groupBy asArray (if groupBy given); sends via self unifiedCommand: args; parses the result via a new private tsParseMRangeResult:groupBy: dispatcher.

   Call it with cmdName ''TS.MRANGE'' from the three tsMRangeBy:... methods (the TS.MREVRANGE methods come in the next step and must reuse this same private executor).

6. Parsing: rawResult ifNil: [ ^ #() ]. Each row is { keyOrGroupString. labelPairs. samples }. Reuse tsLabelsDictionaryFrom: on labelPairs and tsParseRangeSamples: on samples (both already exist, do not rewrite them) for both grouped and ungrouped rows.
   - Ungrouped (groupBy nil): RsTsRangeValue key: row first labels: (self tsLabelsDictionaryFrom: row second) values: (self tsParseRangeSamples: row third).
   - Grouped: labelsDict := self tsLabelsDictionaryFrom: row second. groupByLabel := groupBy label -> (labelsDict at: groupBy label ifAbsent: [nil]). reducer := labelsDict at: ''__reducer__'' ifAbsent: [nil]. sourceKeys := (labelsDict at: ''__source__'' ifAbsent: [''''])  substrings: '',''. Build RsTsGroupedRangeValue with key: row first, labels: labelsDict, groupByLabel:, reducer:, sourceKeys: (as Array), values: (self tsParseRangeSamples: row third).

Tests to write first (TDD) in src/RediStick-TimeSeries-Tests/:
- RsTsMRangeOptionsTest (plain TestCase, mirror RsTsAggregationOptionsTest''s structure): cover LATEST, FILTER_BY_TS, FILTER_BY_VALUE, SELECTED_LABELS-vs-WITHLABELS precedence, COUNT, and a combined-ordering case.
- RsTsGroupByTest (plain TestCase, mirror RsTsAggregationTest''s structure): asArray shape, and missing label/reducer signals Error.
- RsTsMRangeTest (extends RsRedisTestCase, mirror RsTsMGetTest.class.st''s structure and use RsRedisTestCase dbIndex like it does): a plain multi-key tsMRangeBy:filterBy: case asserting RsTsRangeValue key/labels/values; an aggregationBy: case; a groupBy: case asserting RsTsGroupedRangeValue''s groupByLabel/reducer/sourceKeys/values; a "no filters signals Error" case; a "no matching series returns #()" case.

Follow CLAUDE.md''s workflow: validate each .st file with the smalltalk-validator MCP tool before importing, import both RediStick-TimeSeries and RediStick-TimeSeries-Tests via smalltalk-interop MCP after edits, and run the new test classes via run_class_test. Commit nothing yet (no git commits in this step) — just get the code written and the new tests green in the running image.'.
            t goal: 'RsTsMRangeOptionsTest, RsTsGroupByTest, and RsTsMRangeTest all pass in the running Pharo image' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement TS.MREVRANGE (reuse TS.MRANGE executor)'.
            t prompt: 'Continuing the RediStick TimeSeries work from the previous step (TS.MRANGE is now implemented via a private RsRedisEndpoint>>tsExecuteMRange:rangeBy:filterBy:aggregationBy:groupBy:using: executor), now add TS.MREVRANGE support with NO duplicated logic: it must call the exact same private executor, passing cmdName ''TS.MREVRANGE'' instead of ''TS.MRANGE''.

Add these three public methods to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st, mirroring the tsMRangeBy:... methods added previously and delegating to the same private tsExecuteMRange:rangeBy:filterBy:aggregationBy:groupBy:using: helper:
   tsMRevRangeBy: rangeBlock filterBy: filterBlock
   tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: optionsBlock
   tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock

Write a new test class first (TDD), src/RediStick-TimeSeries-Tests/RsTsMRevRangeTest.class.st (extends RsRedisTestCase, mirror RsTsMRangeTest''s structure): at minimum, add several timestamped samples to one or two series, call tsMRevRangeBy:filterBy: and tsMRangeBy:filterBy: with the same range/filter, and assert the MREVRANGE result''s values come back with timestamps in descending order (opposite of MRANGE''s ascending order) for the same underlying data — this is enough to prove TS.MREVRANGE is wired correctly through the shared executor; do not duplicate every TS.MRANGE test case.

Follow the same workflow as before: validate with smalltalk-validator, import both RediStick-TimeSeries and RediStick-TimeSeries-Tests via smalltalk-interop MCP, run the new test class via run_class_test. No git commits yet.'.
            t goal: 'RsTsMRevRangeTest passes in the running Pharo image' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Run full TimeSeries test suite'.
            t prompt: 'In the RediStick repo, re-import the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages via the smalltalk-interop MCP import_package tool (to be sure the running Pharo image reflects the latest .st files from the previous two steps), then run the full RediStick-TimeSeries-Tests package test suite via the smalltalk-interop MCP run_package_test tool (or run_class_test across every test class in that package, including the pre-existing RsTsTest, RsTsFilterTest, RsTsFilterBuilderTest, RsTsMAddTest, RsTsQueryIndexTest, RsTsRangeTest, RsTsRangeOptionsTest, RsTsValueTest, RsTsAggregationTest, RsTsAggregationOptionsTest, RsTsMGetOptionsTest, RsTsMGetTest, plus the new RsTsMRangeOptionsTest, RsTsGroupByTest, RsTsMRangeTest, RsTsMRevRangeTest). Report a plain-text pass/fail count per test class and flag any regressions in the pre-existing tests caused by the new TS.MRANGE/TS.MREVRANGE code. Do not fix anything yet if something fails — just report exactly what failed and why (error message / assertion) so the next step or a human can act on it.' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Lint and style review'.
            t prompt: 'Review all the .st files added or changed in the RediStick repo for the TS.MRANGE/TS.MREVRANGE feature (src/RediStick-TimeSeries/RsTsMRangeOptions.class.st, RsTsGroupBy.class.st, RsTsRangeValue.class.st, RsTsGroupedRangeValue.class.st, RsRedisEndpoint.extension.st, and src/RediStick-TimeSeries-Tests/RsTsMRangeOptionsTest.class.st, RsTsGroupByTest.class.st, RsTsMRangeTest.class.st, RsTsMRevRangeTest.class.st). Consult the st-lint skill (or the smalltalk-validator MCP tools directly) against each changed Tonel file, and consult the smalltalk-developer skill''s style guide / best-practices section (method categorization, CRC-style class comments, Tonel syntax conventions). Fix whatever issues are found — lint warnings, missing or wrong method categories, missing class comments, style inconsistencies with the rest of the RediStick-TimeSeries package. After fixing, re-import the affected packages and re-run the previously-passing tests to confirm nothing broke from the cleanup. If any test regressed from the previous step''s report, fix the underlying cause here too.'.
            t goal: 'lint clean and style-guide issues fixed, with all RediStick-TimeSeries-Tests still passing' ]
    } agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'TS.MRANGE/TS.MREVRANGE orchestration done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:` runs the orchestration in the background and returns immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript), or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
