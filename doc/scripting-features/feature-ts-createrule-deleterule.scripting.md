# Feature: TS.CREATERULE / TS.DELETERULE support

## Goal

`RsRedisEndpoint` supports Redis TimeSeries compaction rule management:
- `tsCreateRule:dest:aggregationBy:alignTimestamp:`
- `tsCreateRule:dest:aggregationBy:`
- `tsDeleteRule:dest:`

All backed by real `TS.CREATERULE` / `TS.DELETERULE` Redis commands, following the existing `RediStick-TimeSeries` package patterns (see `tsAlter:using:`, `tsExecuteRange:...` and `RsTsAggregation` for the `AGGREGATION aggregator bucketDuration` clause), with passing tests and clean lint.

## Orchestration Shape

sequential: implement (TDD) → test → lint & review, all via claude

## Working Directory

/home/mumez/git/RediStick

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Implement TS.CREATERULE / TS.DELETERULE (TDD)'.
			t prompt: 'In the RediStick project (Pharo Smalltalk Redis client), implement support for the Redis TimeSeries commands TS.CREATERULE and TS.DELETERULE in the RediStick-TimeSeries package (see src/RediStick-TimeSeries and src/RediStick-TimeSeries-Tests, Tonel format).

Follow strict TDD: write failing tests first (add them to RsTsTest in src/RediStick-TimeSeries-Tests/RsTsTest.class.st, following the existing style of methods like testTsAlterBasic — create a key with tsCreate:, exercise the new method, then assert on tsInfo: results such as the "rules" field), then implement the methods, then get the tests passing. Reimport the packages into the running Pharo image after each edit (see CLAUDE.md for the smalltalk-interop MCP workflow: import_package for RediStick-TimeSeries and RediStick-TimeSeries-Tests, then run_class_test for RsTsTest) and iterate until green.

Add these methods to the RsRedisEndpoint extension in src/RediStick-TimeSeries/RsRedisEndpoint.extension.st, next to the other ts* methods:

1. `RsRedisEndpoint >> tsCreateRule: sourceKey dest: destKey aggregationBy: aggregationBlock`
   Sends `TS.CREATERULE sourceKey destKey AGGREGATION aggregator bucketDuration`.
   `aggregationBlock` is evaluated with a fresh `RsTsAggregation` instance (see src/RediStick-TimeSeries/RsTsAggregation.class.st), whose `asArray` already produces `{ ''AGGREGATION''. aggregatorsString. bucketDuration }` — reuse it exactly as `tsExecuteRange:` does for range aggregation, e.g. `args addAll: aggregation asArray`.

2. `RsRedisEndpoint >> tsCreateRule: sourceKey dest: destKey aggregationBy: aggregationBlock alignTimestamp: tsMSecsOrDateTime`
   Same as above but appends the optional `[alignTimestamp]` positional argument after the bucketDuration (per the TS.CREATERULE spec: `TS.CREATERULE sourceKey destKey AGGREGATION aggregator bucketDuration [alignTimestamp]`). Convert `tsMSecsOrDateTime` the same way other timestamp parameters in this package do, via `asRediStickUnixTimestampMillis` (see tsAdd:timestamp:value: for the pattern). Have the two-argument overload (#1) delegate to a shared private helper, or have it call this method with `alignTimestamp: nil` and omit the arg when nil — follow whichever existing pattern in RsRedisEndpoint.extension.st (e.g. tsIncrOrDecr:key:timestamp:value:using:) looks cleanest for optional trailing args.

3. `RsRedisEndpoint >> tsDeleteRule: sourceKey dest: destKey`
   Sends `TS.DELETERULE sourceKey destKey`. No options.

Reference for exact command syntax: https://redis.io/docs/latest/commands/ts.createrule/ and https://redis.io/docs/latest/commands/ts.deleterule/ (fetch these if web access is available; otherwise the syntax above is authoritative).

Use `self unifiedCommand: args` to send commands, matching every other ts* method in the file. Both commands return the simple string ''OK'' on success — assert that in tests, then verify via tsInfo: on the source key that a "rules" entry now references the destination key (and is empty/absent after tsDeleteRule:dest:).

Do not modify any test or method outside the ones described above.'.
			t goal: 'tsCreateRule:dest:aggregationBy:, tsCreateRule:dest:aggregationBy:alignTimestamp:, and tsDeleteRule:dest: are implemented in RsRedisEndpoint.extension.st, corresponding tests exist in RsTsTest, and those tests pass when run via the run_class_test MCP tool' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Run full TimeSeries test suite'.
			t prompt: 'In the RediStick project, reimport the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages (smalltalk-interop MCP import_package, absolute path /home/mumez/git/RediStick/src) and then run the full RsTsTest test class (run_class_test), not just the new tests from the previous step. Report the pass/fail counts and paste any failure details. If anything fails, fix the regression in the TimeSeries package (do not touch unrelated packages) and rerun until the whole RsTsTest suite is green. Also run any other TimeSeries-related test classes in src/RediStick-TimeSeries-Tests (RsTsAggregationTest, RsTsRangeOptionsTest, RsTsMAddTest, RsTsMGetTest, RsTsQueryIndexTest, etc.) to confirm no regressions, and report their results too.' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Lint and style review'.
			t prompt: 'In the RediStick project, review the changes made in this session to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st and src/RediStick-TimeSeries-Tests/RsTsTest.class.st for lint and style issues. Use the st-lint skill (or the smalltalk-validator MCP tools: lint_tonel_smalltalk_from_file / validate_tonel_smalltalk_from_file) against both changed Tonel files, and also consult the smalltalk-developer skill''s style guide section (method categorization, formatting conventions used elsewhere in this file, e.g. category tags like `*RediStick-TimeSeries` and `*RediStick-TimeSeries-private`). Fix anything the lint tool flags and anything that deviates from the surrounding code''s conventions (naming, argument order, use of private category for internal helpers). Reimport the packages after fixing and rerun RsTsTest to confirm it is still green after your changes.'.
			t goal: 'lint clean and style-guide issues fixed' ]
	} agentBy: [ :a | a claude ]
].
script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:` runs the orchestration in the background and returns immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript), or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
