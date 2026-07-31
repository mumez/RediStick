# Feature: TS.QUERYINDEX support

## Goal

Add `RsRedisEndpoint >> tsQueryIndexFilterBy: filterBlock` to the `RediStick-TimeSeries` package, implementing Redis's `TS.QUERYINDEX` command by reusing the existing `RsTsFilterBuilder`/`RsTsFilter` filter machinery already used by `tsMGetFilterBy:`. It should return the raw array of matching time-series key names, with test coverage on par with the existing `RsTsMGetTest`, and no lint/style issues left behind.

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
			t title: 'Implement TS.QUERYINDEX (TDD)'.
			t prompt: 'Implement TS.QUERYINDEX support in the RediStick-TimeSeries package (Pharo Smalltalk, Tonel format), located at src/RediStick-TimeSeries with tests at src/RediStick-TimeSeries-Tests.

Context:
- TS.MGET is already implemented via `RsRedisEndpoint >> tsMGetFilterBy: filterBlock` and `tsMGetFilterBy: filterBlock using: optionsBlock` in src/RediStick-TimeSeries/RsRedisEndpoint.extension.st. These build a filter expression using `RsTsFilterBuilder` (src/RediStick-TimeSeries/RsTsFilterBuilder.class.st) and `RsTsFilter` (src/RediStick-TimeSeries/RsTsFilter.class.st), which already support `label:eq:`, `label:notEq:`, `label:in:`, `label:notIn:`, `hasLabel:`, `noLabel:`.
- TS.QUERYINDEX (https://redis.io/docs/latest/commands/ts.queryindex/) has the syntax `TS.QUERYINDEX filterExpr...` and returns an array of key names for all time series matching the given filter list. It takes no other options.
- Design doc: doc/specs/2026-07-13-timeseries-commands-design.md — follow its conventions, in particular "Query Result Representation": do not introduce a dedicated result-wrapper class where the raw Redis result is already usable.

Task (write tests first, then implement, then make them pass):
1. Add `RsRedisEndpoint >> tsQueryIndexFilterBy: filterBlock` to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st that:
   - Builds an `RsTsFilterBuilder`, evaluates `filterBlock` with it (same pattern as `tsMGetFilterBy:using:`).
   - Signals an Error if no filters were added, reusing the message "At least one filter expression is required" (same as `tsMGetFilterBy:using:`).
   - Sends `TS.QUERYINDEX FILTER filter1 filter2 ...` via `self unifiedCommand:`.
   - Returns the raw array of matching key name Strings as returned by Redis, unwrapped.
2. Create a new test class `RsTsQueryIndexTest` (subclass of `RsRedisTestCase`) in src/RediStick-TimeSeries-Tests/RsTsQueryIndexTest.class.st, following the structure and conventions of src/RediStick-TimeSeries-Tests/RsTsMGetTest.class.st (test keys scoped via `RsRedisTestCase dbIndex`, series created with `tsCreate:using:` and labels). Cover at minimum: single filter match, multiple conjunctive filters, a `label:in:` filter, no-match returns an empty array, and calling with no filters raises an Error. Write these tests before the implementation exists (they should fail first), then implement, then iterate until all pass.
3. Follow the Tonel style guide and implementation patterns from the `smalltalk-dev:smalltalk-developer` skill.
4. After every file change, reimport the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages via the smalltalk-interop MCP (or the st-import skill) before running tests, and run RsTsQueryIndexTest via the smalltalk-interop MCP run_class_test tool (or the st-test skill).

Do not modify any file outside src/RediStick-TimeSeries and src/RediStick-TimeSeries-Tests.'.
			t goal: 'RsTsQueryIndexTest test class exists with tests covering single filter, conjunctive filters, label:in:, no-match, and no-filter-error cases, and all of them pass' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Run full TimeSeries regression suite'.
			t prompt: 'In the RediStick repository at /home/mumez/git/RediStick, reimport the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages (smalltalk-interop MCP import_package, or the st-import skill), then run the full RediStick-TimeSeries-Tests package test suite (smalltalk-interop MCP run_package_test, or the st-test skill) to confirm the TS.QUERYINDEX implementation added in the previous step introduced no regressions. Explicitly report pass/fail counts for each test class in that package: RsTsTest, RsTsMGetTest, RsTsFilterBuilderTest, RsTsFilterTest, RsTsMAddTest, RsTsMGetOptionsTest, RsTsRangeTest, RsTsRangeOptionsTest, RsTsAggregationTest, RsTsAggregationOptionsTest, RsTsValueTest, and RsTsQueryIndexTest. If any test fails, fix the regression in the TS.QUERYINDEX changes (do not alter unrelated pre-existing tests) and re-run until the whole package suite is green.' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Lint and style review'.
			t prompt: 'Review the Tonel files changed for TS.QUERYINDEX support in the RediStick repository at /home/mumez/git/RediStick: src/RediStick-TimeSeries/RsRedisEndpoint.extension.st and the new src/RediStick-TimeSeries-Tests/RsTsQueryIndexTest.class.st (plus any other file touched by the previous two steps). Consult the `st-lint` skill (or the smalltalk-validator MCP `lint_tonel_smalltalk_from_file` tool) against each changed file, and consult the `smalltalk-dev:smalltalk-developer` skill''s Tonel style guide section. Fix any lint findings or style-guide deviations (method categorization, formatting, and this project''s CLAUDE.md rule to default to no comments unless the WHY is non-obvious). After fixing, reimport the affected packages and re-run RsTsQueryIndexTest to confirm it is still green.'.
			t goal: 'lint clean and style-guide issues fixed' ]
	} agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:` runs the orchestration in the background and returns immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript), or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
