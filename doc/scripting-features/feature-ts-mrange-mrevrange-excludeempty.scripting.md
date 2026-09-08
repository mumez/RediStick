# Feature: TS.MRANGE / TS.MREVRANGE EXCLUDEEMPTY support

## Goal

`RsTsMRangeOptions` supports an `excludeEmpty` flag that, when set, causes `TS.MRANGE`/`TS.MREVRANGE`
(both routed through the shared `tsExecuteMRange:...` executor) to send the `EXCLUDEEMPTY` token as
the very last argument of the command (after `FILTER ...` and after any `GROUPBY ...` clause) — never
inside `RsTsMRangeOptions>>asArray`'s own output, since that array is spliced in before `FILTER`.
Combining `excludeEmpty` with a `groupBy:` block signals an `Error` (mirroring Redis's own restriction).
Covered by passing tests in `RsTsMRangeOptionsTest`, `RsTsMRangeTest`, and `RsTsMRevRangeTest`.

## Orchestration Shape

3 sequential `seq:` blocks, all via `claude`: implement (TDD) → run full TimeSeries test suite → lint & style review.

## Working Directory

`/home/mumez/git/RediStick` (existing checked-out RediStick repo, current branch `feature/ts-support_v810_3`).

## Design Notes (from prior analysis — implementers should follow this, not redesign it)

Existing reference points, read these first to match conventions exactly:
- `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`: `tsExecuteMRange:rangeBy:filterBy:aggregationBy:groupBy:using:` (shared private executor for both TS.MRANGE and TS.MREVRANGE), `tsMRangeArgsFor:cmdName:range:options:aggOptions:filterBuilder:groupBy:` (private, builds the full args array; currently ends with `FILTER`, the filter strings, then `groupBy asArray` if a group-by was given), `tsParseMRangeResult:groupBy:`.
- `src/RediStick-TimeSeries/RsTsMRangeOptions.class.st`: existing option class (instVars `latest`, `filterByTs`, `filterByValueMin`, `filterByValueMax`, `withLabels`, `selectedLabels`, `count`) whose `asArray` output is spliced into the args array **before** the `FILTER` token. Follow its existing "set to true" idiom: a no-arg method like `latest` sets the flag, paired with an `isLatest` boolean reader.
- `src/RediStick-TimeSeries/RsTsFilterBuilder.class.st`: shows the existing validation-error idiom used in this package — `(RsError invalidArguments) signal: 'message text'`.

Per the official Redis command grammar (verified against the docs), `EXCLUDEEMPTY` is the **last** token
in the whole command — after `FILTER filterExpr...` and after the optional `GROUPBY label REDUCE reducer`
clause, NOT among the other options (`LATEST`/`FILTER_BY_TS`/`FILTER_BY_VALUE`/`WITHLABELS`/
`SELECTED_LABELS`/`COUNT`) that are emitted before `FILTER`. Redis also rejects combining `EXCLUDEEMPTY`
with `GROUPBY label REDUCE reducer`.

### Changes to `RsTsMRangeOptions` (`src/RediStick-TimeSeries/RsTsMRangeOptions.class.st`)

- Add instance var `excludeEmpty`, initialized to `false` alongside the existing `latest := false. withLabels := false.`
- Add a no-arg `excludeEmpty` method that sets it to `true` (mirroring the `latest`/`withLabels` idiom exactly) and an `isExcludeEmpty` boolean reader.
- Do **not** add `EXCLUDEEMPTY` to `asArray`'s output — it must stay absent from `RsTsMRangeOptions>>asArray` even when `excludeEmpty` is set, because it belongs at the very end of the whole command, not before `FILTER` like the other options.

### Changes to `RsRedisEndpoint.extension.st`

- In `tsMRangeArgsFor:cmdName:range:options:aggOptions:filterBuilder:groupBy:`, after the existing `groupBy ifNotNil: [ args addAll: groupBy asArray ]` line (i.e. at the very end of the built args, after `FILTER` and after any `GROUPBY` clause), add: `(options notNil and: [ options isExcludeEmpty ]) ifTrue: [ args add: 'EXCLUDEEMPTY' ]`.
- In `tsExecuteMRange:rangeBy:filterBy:aggregationBy:groupBy:using:`, after `groupBy` and `options` are both built (after the existing `groupingBlock ifNotNil: [...]` block, before the existing selectedLabels-merge block), add a check that signals `(RsError invalidArguments) signal: 'EXCLUDEEMPTY cannot be used together with GROUPBY'` if `groupBy notNil and: [ options notNil and: [ options isExcludeEmpty ] ]`.

Because `TS.MRANGE` and `TS.MREVRANGE` both call this same shared executor and arg-builder, this one
implementation covers both commands — no separate MREVRANGE-specific production code is needed, but
MREVRANGE must still get its own test proving it too respects `EXCLUDEEMPTY` (reusing the shared path
is exactly what should be verified, not assumed).

### Tests to add/extend (in `src/RediStick-TimeSeries-Tests/`)

- `RsTsMRangeOptionsTest` (extend the existing class): a test that `excludeEmpty; isExcludeEmpty` returns `true`, and a test that `asArray` remains `#()` (or unaffected by the flag) when only `excludeEmpty` is set — proving it's deliberately excluded from the options array.
- `RsTsMRangeTest` (extend the existing class, follow its existing setup style using `RsRedisTestCase dbIndex` / `tsCreate:using:` / `tsAdd:timestamp:value:`): a case mirroring the official Redis doc example — create 2-3 series sharing a label, add samples so at least one series has zero samples within the queried range, call `tsMRangeBy:filterBy:using:` with `excludeEmpty` set and assert the empty series is absent from the result (vs. present with an empty values array when the flag is not set). Also add a case asserting that combining `excludeEmpty` with a `groupBy:` block signals an `Error`.
- `RsTsMRevRangeTest` (extend the existing class): at least one case proving `tsMRevRangeBy:filterBy:using:` with `excludeEmpty` set also excludes empty series (reusing the shared executor) — no need to duplicate every `RsTsMRangeTest` case.

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement TS.MRANGE/TS.MREVRANGE EXCLUDEEMPTY (TDD)'.
            t prompt: 'In the RediStick repo (Pharo Smalltalk Redis client, Tonel format), add support for the Redis 8.10 EXCLUDEEMPTY option to TS.MRANGE and TS.MREVRANGE, following Test-Driven Development: write failing tests first, then implement, then get them green.

Background: TS.MRANGE/TS.MREVRANGE are already implemented and share one private executor. Redis''s EXCLUDEEMPTY option "excludes from the reply any time series that has no samples in the requested range. By default, every time series that passes FILTER filterExpr... is reported, even those with no samples in the range (reported with an empty samples list). A time series whose only samples in the range are NaN is not considered empty and is still reported. EXCLUDEEMPTY cannot be used together with GROUPBY label REDUCE reducer; combining them replies with an error." Per the official command grammar, EXCLUDEEMPTY is the LAST token in the whole command — after FILTER filterExpr... and after the optional GROUPBY label REDUCE reducer clause, NOT among the other options (LATEST/FILTER_BY_TS/FILTER_BY_VALUE/WITHLABELS/SELECTED_LABELS/COUNT) that are emitted before FILTER.

Read these existing files first to match conventions exactly before writing anything:
- src/RediStick-TimeSeries/RsRedisEndpoint.extension.st (methods: tsExecuteMRange:rangeBy:filterBy:aggregationBy:groupBy:using:, tsMRangeArgsFor:cmdName:range:options:aggOptions:filterBuilder:groupBy:, tsParseMRangeResult:groupBy:)
- src/RediStick-TimeSeries/RsTsMRangeOptions.class.st
- src/RediStick-TimeSeries/RsTsFilterBuilder.class.st (for the `(RsError invalidArguments) signal: ''...''` validation idiom used in this package)
- src/RediStick-TimeSeries-Tests/RsTsMRangeOptionsTest.class.st, RsTsMRangeTest.class.st, RsTsMRevRangeTest.class.st (existing test style/structure to extend)
- CLAUDE.md''s Development and Testing Workflow section for the smalltalk-interop/smalltalk-validator MCP workflow (import_package after every .st edit, validate_tonel_smalltalk_from_file before importing, run_class_test / run_package_test to check)

Build exactly this design (do not redesign it):

1. In RsTsMRangeOptions.class.st: add instance var excludeEmpty, initialized to false alongside the existing `latest := false. withLabels := false.` in `initialize`. Add a no-arg `excludeEmpty` method that sets it to true (mirroring the `latest`/`withLabels` idiom exactly: calling the method with no argument sets the flag) and an `isExcludeEmpty` boolean reader. Do NOT add EXCLUDEEMPTY to `asArray`''s output under any circumstance — it must stay absent from RsTsMRangeOptions>>asArray even when excludeEmpty is set, because in the real command grammar it belongs at the very end of the whole command (after FILTER and GROUPBY), not among the options emitted before FILTER.

2. In RsRedisEndpoint.extension.st, in `tsMRangeArgsFor:cmdName:range:options:aggOptions:filterBuilder:groupBy:`, after the existing `groupBy ifNotNil: [ args addAll: groupBy asArray ]` line (i.e. at the very end of the built args), add: `(options notNil and: [ options isExcludeEmpty ]) ifTrue: [ args add: ''EXCLUDEEMPTY'' ]`.

3. In RsRedisEndpoint.extension.st, in `tsExecuteMRange:rangeBy:filterBy:aggregationBy:groupBy:using:`, after `groupBy` and `options` are both built (after the existing `groupingBlock ifNotNil: [...]` block, before the existing selectedLabels-merge block), add a check that signals `(RsError invalidArguments) signal: ''EXCLUDEEMPTY cannot be used together with GROUPBY''` if `groupBy notNil and: [ options notNil and: [ options isExcludeEmpty ] ]`.

Because TS.MRANGE and TS.MREVRANGE both call this same shared executor and arg-builder, this one implementation covers both commands — no separate MREVRANGE-specific production code is needed, but MREVRANGE must still get its own test proving it too respects EXCLUDEEMPTY (reusing the shared path is exactly what should be verified, not assumed).

Tests to write first (TDD) in src/RediStick-TimeSeries-Tests/:
- RsTsMRangeOptionsTest (extend the existing class): a test that `excludeEmpty; isExcludeEmpty` returns true, and a test that `asArray` remains `#()` (or unaffected by the flag) when only excludeEmpty is set.
- RsTsMRangeTest (extend the existing class, follow its existing setup style using RsRedisTestCase dbIndex / tsCreate:using: / tsAdd:timestamp:value:): a case mirroring the official Redis doc EXCLUDEEMPTY example — create 2-3 series sharing a label, add samples so at least one series has zero samples within the queried range, call tsMRangeBy:filterBy:using: with excludeEmpty set and assert the empty series is absent from the result (vs. present with an empty values array when the flag is not set). Also add a case asserting that combining excludeEmpty with a groupBy: block signals an Error.
- RsTsMRevRangeTest (extend the existing class): at least one case proving tsMRevRangeBy:filterBy:using: with excludeEmpty set also excludes empty series (reusing the shared executor) — no need to duplicate every RsTsMRangeTest case.

Follow CLAUDE.md''s workflow: validate each .st file with the smalltalk-validator MCP tool before importing, import both RediStick-TimeSeries and RediStick-TimeSeries-Tests via smalltalk-interop MCP after edits, and run the new/changed test classes via run_class_test. Commit nothing yet (no git commits in this step) — just get the code written and the new/changed tests green in the running image.'.
            t goal: 'RsTsMRangeOptionsTest, RsTsMRangeTest, and RsTsMRevRangeTest all pass in the running Pharo image, including the new EXCLUDEEMPTY cases' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Run full TimeSeries test suite'.
            t prompt: 'In the RediStick repo, re-import the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages via the smalltalk-interop MCP import_package tool (to be sure the running Pharo image reflects the latest .st files from the previous step), then run the full RediStick-TimeSeries-Tests package test suite via the smalltalk-interop MCP run_package_test tool (or run_class_test across every test class in that package). Report a plain-text pass/fail count per test class and flag any regressions caused by the new EXCLUDEEMPTY code. Do not fix anything yet if something fails — just report exactly what failed and why (error message / assertion) so the next step or a human can act on it.' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Lint and style review'.
            t prompt: 'Review all the .st files added or changed in the RediStick repo for the TS.MRANGE/TS.MREVRANGE EXCLUDEEMPTY feature (src/RediStick-TimeSeries/RsTsMRangeOptions.class.st, RsRedisEndpoint.extension.st, and src/RediStick-TimeSeries-Tests/RsTsMRangeOptionsTest.class.st, RsTsMRangeTest.class.st, RsTsMRevRangeTest.class.st). Consult the st-lint skill (or the smalltalk-validator MCP tools directly) against each changed Tonel file, and consult the smalltalk-developer skill''s style guide / best-practices section (method categorization, CRC-style class comments, Tonel syntax conventions). Fix whatever issues are found — lint warnings, missing or wrong method categories, missing class comments, style inconsistencies with the rest of the RediStick-TimeSeries package. After fixing, re-import the affected packages and re-run the previously-passing tests to confirm nothing broke from the cleanup. If any test regressed from the previous step''s report, fix the underlying cause here too.'.
            t goal: 'lint clean and style-guide issues fixed, with all RediStick-TimeSeries-Tests still passing' ]
    } agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'TS.MRANGE/TS.MREVRANGE EXCLUDEEMPTY orchestration done: ' , orc result ]
    onTimeout: [ :timeoutStep :ex | Transcript crShow: 'TS.MRANGE/TS.MREVRANGE EXCLUDEEMPTY orchestration timed out at step: ' , timeoutStep printString ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:onTimeout:` runs the orchestration in the background and returns immediately — watch for the completion block's own report (e.g. via Transcript), the `onTimeout:` block's report if a step stalls, or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
