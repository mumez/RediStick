# Feature: TS.MGET support for RediStick-TimeSeries

## Goal

Implement `RsRedisEndpoint >> tsMGetFilterBy:` / `tsMGetFilterBy:using:` (and the four supporting
value classes `RsTsFilter`, `RsTsFilterBuilder`, `RsTsMGetOptions`, `RsTsValue`) exactly as specified
in `doc/plans/2026-07-18-ts-mget.md`, with all new/updated tests green and a clean full-package
regression + lint pass at the end.

## Orchestration Shape

Sequential, one `seq:` block per plan task (6 blocks total), all via `claude`:

1. Task 1 — `RsTsFilter`
2. Task 2 — `RsTsFilterBuilder`
3. Task 3 — `RsTsMGetOptions`
4. Task 4 — `RsTsValue`
5. Task 5 — `RsRedisEndpoint >> tsMGetFilterBy:` / `tsMGetFilterBy:using:` (integration tests)
6. Task 6 — full-package regression check + lint

Each task is its own `seq:` block (rather than bundling all 6 into one) so that if a step fails or
times out, only that task's block retries — it does not replay earlier, already-committed tasks.
The `sharedDirectoryPath:` points every step at the same real repo/live Pharo image, so tasks run
strictly one after another (no `para:`) to avoid two agents importing packages or committing to the
same repo/image concurrently.

## Working Directory

`/home/mumez/git/RediStick` (the current RediStick checkout, on branch `feature/time-series`).

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.MGET Task 1: RsTsFilter'.
			t prompt: 'Open doc/plans/2026-07-18-ts-mget.md in this repository and follow Task 1 ("RsTsFilter — single FILTER expression value object") exactly, step by step (Steps 1-5): write the failing RsTsFilterTest test file, validate and import it via the smalltalk-validator/smalltalk-interop MCP tools to confirm it fails as expected (RsTsFilter class not found), then create RsTsFilter.class.st with the exact implementation given in the plan, validate + reimport both RediStick-TimeSeries and RediStick-TimeSeries-Tests, run RsTsFilterTest via mcp__smalltalk-interop__run_class_test and confirm all 7 tests pass, then git add + commit exactly as instructed in Step 5. Do not modify any other class or method outside this task''s scope. Check off each "- [ ]" box for Task 1 in the plan file as you complete it.'.
			t goal: 'RsTsFilter.class.st and RsTsFilterTest.class.st exist exactly as specified, RsTsFilterTest (7/7) passes, Task 1''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.MGET Task 2: RsTsFilterBuilder'.
			t prompt: 'Open doc/plans/2026-07-18-ts-mget.md in this repository and follow Task 2 ("RsTsFilterBuilder — accumulates filters for tsMGetFilterBy:") exactly, step by step (Steps 1-5): write the failing RsTsFilterBuilderTest test file, validate/import to confirm the expected "class not found" failure, then create RsTsFilterBuilder.class.st with the exact implementation given in the plan, validate + reimport RediStick-TimeSeries and RediStick-TimeSeries-Tests, run RsTsFilterBuilderTest and confirm all 5 tests pass, then commit exactly as instructed in Step 5. RsTsFilter from Task 1 already exists in this repo (implemented in a prior step) — do not recreate or modify it. Check off Task 2''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RsTsFilterBuilder.class.st and RsTsFilterBuilderTest.class.st exist exactly as specified, RsTsFilterBuilderTest (5/5) passes, Task 2''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.MGET Task 3: RsTsMGetOptions'.
			t prompt: 'Open doc/plans/2026-07-18-ts-mget.md in this repository and follow Task 3 ("RsTsMGetOptions — LATEST / WITHLABELS / SELECTED_LABELS flags") exactly, step by step (Steps 1-5): write the failing RsTsMGetOptionsTest test file, validate/import to confirm the expected "class not found" failure, then create RsTsMGetOptions.class.st with the exact implementation given in the plan, validate + reimport RediStick-TimeSeries and RediStick-TimeSeries-Tests, run RsTsMGetOptionsTest and confirm all 6 tests pass, then commit exactly as instructed in Step 5. Do not touch RsTsFilter or RsTsFilterBuilder from earlier tasks. Check off Task 3''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RsTsMGetOptions.class.st and RsTsMGetOptionsTest.class.st exist exactly as specified, RsTsMGetOptionsTest (6/6) passes, Task 3''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.MGET Task 4: RsTsValue'.
			t prompt: 'Open doc/plans/2026-07-18-ts-mget.md in this repository and follow Task 4 ("RsTsValue — TS.MGET result value object") exactly, step by step (Steps 1-5): write the failing RsTsValueTest test file, validate/import to confirm the expected "class not found" failure, then create RsTsValue.class.st with the exact implementation given in the plan, validate + reimport RediStick-TimeSeries and RediStick-TimeSeries-Tests, run RsTsValueTest and confirm both tests pass, then commit exactly as instructed in Step 5. Do not touch the classes from earlier tasks. Check off Task 4''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RsTsValue.class.st and RsTsValueTest.class.st exist exactly as specified, RsTsValueTest (2/2) passes, Task 4''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.MGET Task 5: tsMGetFilterBy:/tsMGetFilterBy:using:'.
			t prompt: 'Open doc/plans/2026-07-18-ts-mget.md in this repository and follow Task 5 ("RsRedisEndpoint >> tsMGetFilterBy: / tsMGetFilterBy:using:") exactly, step by step (Steps 1-5). RsTsFilter, RsTsFilterBuilder, RsTsMGetOptions, and RsTsValue from Tasks 1-4 already exist in this repo (implemented in prior steps) — reuse them, do not recreate them. Write the failing RsTsMGetTest integration test file exactly as given, validate/import to confirm the expected failure (doesNotUnderstand or import error for tsMGetFilterBy:), then append the given methods to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st exactly as specified (do not touch any existing method in that file), validate + reimport RediStick-TimeSeries and RediStick-TimeSeries-Tests, then run RsTsMGetTest via mcp__smalltalk-interop__run_class_test against the live Redis/RedisTimeSeries instance. This requires a live Redis connection the same way every other RsTsTest/RsTsMAddTest integration test in this package already does — if no live Redis is reachable in this environment, report that explicitly rather than claiming the tests passed. Once all 10 tests pass, commit exactly as instructed in Step 5. Check off Task 5''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RsRedisEndpoint.extension.st has the new tsMGetFilterBy:/tsMGetFilterBy:using: methods and private helpers exactly as specified, RsTsMGetTest.class.st exists exactly as specified, RsTsMGetTest (10/10) passes against a live Redis instance (or the run clearly reports why a live Redis instance is unavailable), Task 5''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.MGET Task 6: regression check + lint & review'.
			t prompt: 'Open doc/plans/2026-07-18-ts-mget.md in this repository and follow Task 6 ("Full-package regression check") exactly: run mcp__smalltalk-interop__run_package_test for RediStick-TimeSeries-Tests and confirm 0 failures/0 errors across all classes (RsTsTest, RsTsMAddTest, RsTsRangeTest, RsTsAggregationTest, RsTsAggregationOptionsTest, RsTsRangeOptionsTest, plus the five new classes RsTsFilterTest, RsTsFilterBuilderTest, RsTsMGetOptionsTest, RsTsValueTest, RsTsMGetTest added in Tasks 1-5). Then run mcp__smalltalk-validator__lint_tonel_smalltalk_from_file on every file created or modified across Tasks 1-5 (RsTsFilter.class.st, RsTsFilterBuilder.class.st, RsTsMGetOptions.class.st, RsTsValue.class.st, RsRedisEndpoint.extension.st, and their five test files). Also consult the smalltalk-dev:smalltalk-developer skill''s style guide section and the st-lint skill for the project''s Tonel style conventions, and fix any issues either tool reports, re-running the affected class test after each fix. If any fixes were needed, commit them as instructed in Step 3 of Task 6 ("Fix lint findings in TS.MGET implementation"); if nothing needed fixing, skip that commit (no empty commits) as the plan says. Check off Task 6''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RediStick-TimeSeries-Tests package test run reports 0 failures/0 errors across all listed classes, lint has been run on every file touched in Tasks 1-5 with all findings fixed, Task 6''s checkboxes are checked in the plan file, and (only if fixes were needed) a lint-fix commit exists' ]
	} agentBy: [ :a | a claude ] ].

script forkRunThen: [ :orc | Transcript crShow: 'TS.MGET orchestration done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval.
`forkRunThen:` runs the orchestration in the background and returns immediately — watch for the
`forkRunThen:` block's own report (via `Transcript`), or check progress with
`AbOrchestrationManager default orchestrationAt: <orchestration script id>` (the id is the value
`script register` returns/returned by the last line above).
