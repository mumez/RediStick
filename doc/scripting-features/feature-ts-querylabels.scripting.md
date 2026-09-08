# Feature: TS.QUERYLABELS support

## Goal

`RsRedisEndpoint` gains `tsQueryLabels`, `tsQueryLabelsFilterBy:`, `tsQueryLabelValues:`, and `tsQueryLabelValues:filterBy:`, implementing Redis 8.10's `TS.QUERYLABELS` command by reusing the existing `RsTsFilterBuilder`/`RsTsFilter` filter machinery, with test coverage on par with the existing `RsTsQueryIndexTest`, and no lint/style issues left behind.

## Orchestration Shape

Sequential: implement (TDD) → test (regression check across the TimeSeries suite) → lint & review, each its own `seq:` block, all via claude.

## Working Directory

`/home/mumez/git/RediStick`

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Implement TS.QUERYLABELS (TDD)'.
			t prompt: 'Implement TS.QUERYLABELS support in the RediStick-TimeSeries package (Pharo Smalltalk, Tonel format), located at src/RediStick-TimeSeries with tests at src/RediStick-TimeSeries-Tests.

Context on TS.QUERYLABELS (https://redis.io/docs/latest/commands/ts.querylabels/), syntax: `TS.QUERYLABELS <LABELS | VALUES label> [FILTER filterExpr [filterExpr ...]]`:
- `LABELS` subtype returns the distinct label names used by matching time series.
- `VALUES label` subtype returns the distinct values of the given label used by matching time series (empty array, not an error, if the label does not exist).
- `FILTER` is OPTIONAL here (unlike TS.MGET/TS.QUERYINDEX) — when omitted, all indexed time series are considered.
- When FILTER is given, the same constraint as other filter commands applies: at least one filter expression must be an equality matcher (`label=value` or `label=(v1,v2,...)`).
- Return value is a flat array of strings (label names or label values), order undefined, empty array if nothing matches.

Existing code to reuse (do not duplicate this logic, and do not modify these two classes):
- `RsTsFilterBuilder` (src/RediStick-TimeSeries/RsTsFilterBuilder.class.st) and `RsTsFilter` (src/RediStick-TimeSeries/RsTsFilter.class.st) already implement filter-expression building (`label:eq:`, `label:notEq:`, `label:in:`, `label:notIn:`, `hasLabel:`, `noLabel:`) plus a `validate` method that already enforces both "at least one filter" and "at least one equality matcher" — exactly the constraint TS.QUERYLABELS needs when FILTER is supplied.
- `RsRedisEndpoint >> tsQueryIndexFilterBy: filterBlock` (src/RediStick-TimeSeries/RsRedisEndpoint.extension.st, near line 342) is the closest sibling: builds a filter via `RsTsFilterBuilder`, calls `validate`, sends the command via `self unifiedCommand:`, and returns `(result) ifNil: [ #() ] ifNotNil: [ :r | r asArray ]`. Follow the same shape.
- Design doc doc/specs/2026-07-13-timeseries-commands-design.md section "Query Result Representation" says: do not introduce a dedicated result-wrapper class where the raw Redis result is already usable — a flat array of strings is already usable as-is, so no wrapper class is needed here. No new Options-pattern class is needed either since there are no optional parameters beyond the filter, which the existing filter builder already covers.

Requested public API (add to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st), covering both the FILTER-omitted and FILTER-given cases per subtype:
1. `RsRedisEndpoint >> tsQueryLabels` — sends `TS.QUERYLABELS LABELS` (no FILTER clause), returns the raw array of label-name Strings (`#()` if Redis returns nil/empty).
2. `RsRedisEndpoint >> tsQueryLabelsFilterBy: filterBlock` — builds filters via `RsTsFilterBuilder` (same pattern as `tsQueryIndexFilterBy:`), validates, sends `TS.QUERYLABELS LABELS FILTER filter1 filter2 ...`, returns the raw array.
3. `RsRedisEndpoint >> tsQueryLabelValues: aLabel` — sends `TS.QUERYLABELS VALUES aLabel` (no FILTER clause), returns the raw array of value Strings.
4. `RsRedisEndpoint >> tsQueryLabelValues: aLabel filterBy: filterBlock` — same filter-building as #2 but sends `TS.QUERYLABELS VALUES aLabel FILTER filter1 filter2 ...`.

Task (write tests first, then implement, then make them pass):
1. Create a new test class `RsTsQueryLabelsTest` (subclass of `RsRedisTestCase`) in src/RediStick-TimeSeries-Tests/RsTsQueryLabelsTest.class.st, following the structure and conventions of src/RediStick-TimeSeries-Tests/RsTsQueryIndexTest.class.st (test keys/series scoped via `RsRedisTestCase dbIndex`, series created with `tsCreate:using:` and labels). Cover at minimum: `tsQueryLabels` with series scoped via dbIndex isolation, `tsQueryLabelsFilterBy:` with a single filter and with conjunctive filters, `tsQueryLabelValues:` for an existing label, `tsQueryLabelValues:filterBy:` filtered, a `tsQueryLabelValues:` call for a label that does not exist (expect empty array, not an error), and a `tsQueryLabelsFilterBy:`/`tsQueryLabelValues:filterBy:` call whose filter block adds no filters (expect an Error, matching `RsTsFilterBuilder validate`''s existing behavior). Write these tests before the implementation exists (they should fail first), then implement the four methods above, then iterate until all pass.
2. Follow the Tonel style guide and implementation patterns from the `smalltalk-dev:smalltalk-developer` skill.
3. After every file change, reimport the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages via the smalltalk-interop MCP (or the st-import skill) before running tests, and run RsTsQueryLabelsTest via the smalltalk-interop MCP run_class_test tool (or the st-test skill).

Do not modify any file outside src/RediStick-TimeSeries and src/RediStick-TimeSeries-Tests. Do not modify RsTsFilterBuilder or RsTsFilter.'.
			t goal: 'RsTsQueryLabelsTest test class exists with tests covering tsQueryLabels, tsQueryLabelsFilterBy: (single and conjunctive filters), tsQueryLabelValues:, tsQueryLabelValues:filterBy:, a non-existent label returning an empty array, and the no-filter-error case, and all of them pass' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Run full TimeSeries regression suite'.
			t prompt: 'In the RediStick repository at /home/mumez/git/RediStick, reimport the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages (smalltalk-interop MCP import_package, or the st-import skill), then run the full RediStick-TimeSeries-Tests package test suite (smalltalk-interop MCP run_package_test, or the st-test skill) to confirm the TS.QUERYLABELS implementation added in the previous step introduced no regressions. Explicitly report pass/fail counts for each test class in that package: RsTsTest, RsTsMGetTest, RsTsFilterBuilderTest, RsTsFilterTest, RsTsMAddTest, RsTsMGetOptionsTest, RsTsRangeTest, RsTsRangeOptionsTest, RsTsAggregationTest, RsTsAggregationOptionsTest, RsTsValueTest, RsTsQueryIndexTest, and RsTsQueryLabelsTest. If any test fails, fix the regression in the TS.QUERYLABELS changes (do not alter unrelated pre-existing tests) and re-run until the whole package suite is green.' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Lint and style review'.
			t prompt: 'Review the Tonel files changed for TS.QUERYLABELS support in the RediStick repository at /home/mumez/git/RediStick: src/RediStick-TimeSeries/RsRedisEndpoint.extension.st and the new src/RediStick-TimeSeries-Tests/RsTsQueryLabelsTest.class.st (plus any other file touched by the previous two steps). Consult the `st-lint` skill (or the smalltalk-validator MCP `lint_tonel_smalltalk_from_file` tool) against each changed file, and consult the `smalltalk-dev:smalltalk-developer` skill''s Tonel style guide section. Fix any lint findings or style-guide deviations (method categorization, formatting, and this project''s CLAUDE.md rule to default to no comments unless the WHY is non-obvious). After fixing, reimport the affected packages and re-run RsTsQueryLabelsTest to confirm it is still green.'.
			t goal: 'lint clean and style-guide issues fixed' ]
	} agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ]
	onTimeout: [ :timeoutStep :ex | Transcript crShow: 'Timed out: ' , timeoutStep printString ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:onTimeout:` runs the orchestration in the background and returns immediately — watch for the completion block's own report (e.g. via Transcript), the `onTimeout:` block's report if a step stalls, or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
