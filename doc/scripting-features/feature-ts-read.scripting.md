# Feature: TS.READ support for RediStick-TimeSeries

## Goal

Implement `RsRedisEndpoint >> tsRead:cursor:` / `tsRead:cursor:using:` (and the supporting
`RsTsReadOptions` value class) exactly as specified in
`doc/plans/2026-09-07-ts-read-implementation.md`, with all new/updated tests green and a clean
full-package regression + lint pass at the end.

## Orchestration Shape

Sequential, one `seq:` block per plan task (3 blocks total), all via `claude`:

1. Task 1 — `RsTsReadOptions`
2. Task 2 — `RsRedisEndpoint >> tsRead:cursor:` / `tsRead:cursor:using:` (integration tests)
3. Task 3 — full-package regression check + lint

Each task is its own `seq:` block (rather than bundling all 3 into one) so that if a step fails or
times out, only that task's block retries — it does not replay earlier, already-committed tasks.
The `sharedDirectoryPath:` points every step at the same real repo/live Pharo image, so tasks run
strictly one after another (no `para:`) to avoid two agents importing packages or committing to the
same repo/image concurrently.

## Working Directory

`/home/mumez/git/RediStick` (the current RediStick checkout, on branch `feature/ts-support_v810`).

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.READ Task 1: RsTsReadOptions'.
			t prompt: 'Open doc/plans/2026-09-07-ts-read-implementation.md in this repository and follow Task 1 ("RsTsReadOptions value class") exactly, step by step (Steps 1-5): write the failing RsTsReadOptionsTest test file, validate and import it via the smalltalk-validator/smalltalk-interop MCP tools to confirm it fails as expected (RsTsReadOptions class not found), then create RsTsReadOptions.class.st with the exact implementation given in the plan, validate + reimport both RediStick-TimeSeries and RediStick-TimeSeries-Tests, run RsTsReadOptionsTest via mcp__smalltalk-interop__run_class_test and confirm all 6 tests pass, then git add + commit exactly as instructed in Step 5. Do not modify any other class or method outside this task''s scope. Check off each "- [ ]" box for Task 1 in the plan file as you complete it.'.
			t goal: 'RsTsReadOptions.class.st and RsTsReadOptionsTest.class.st exist exactly as specified, RsTsReadOptionsTest (6/6) passes, Task 1''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.READ Task 2: tsRead:cursor:/tsRead:cursor:using:'.
			t prompt: 'Open doc/plans/2026-09-07-ts-read-implementation.md in this repository and follow Task 2 ("RsRedisEndpoint >> tsRead:cursor: / tsRead:cursor:using:") exactly, step by step (Steps 1-5). RsTsReadOptions from Task 1 already exists in this repo (implemented in a prior step) — reuse it, do not recreate or modify it. Also reuse the existing RsTsRange class >> normalizeTimestamp: and RsRedisEndpoint >> tsParseRangeSamples: / tsParseValue: helpers exactly as they already exist — do not touch them. Append the 8 failing test methods to RsTsTest.class.st exactly as given, validate/import to confirm the expected failure (doesNotUnderstand for tsRead:cursor:), then append the two new methods to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st exactly as specified (do not touch any existing method in that file or in RsTsTest.class.st). Validate + reimport RediStick-TimeSeries and RediStick-TimeSeries-Tests, then run RsTsTest via mcp__smalltalk-interop__run_class_test against the live Redis/RedisTimeSeries instance (server must support TS.READ, i.e. Redis 8.10+/RedisTimeSeries built against it). This requires a live Redis connection the same way every other RsTsTest integration test in this package already does — if no live Redis is reachable, or the server does not support TS.READ, report that explicitly rather than claiming the tests passed. Once all RsTsTest tests pass (including the 8 new testTsRead* methods), commit exactly as instructed in Step 5. Check off Task 2''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RsRedisEndpoint.extension.st has the new tsRead:cursor:/tsRead:cursor:using: methods exactly as specified, RsTsTest.class.st has the 8 new testTsRead* methods exactly as specified, all RsTsTest tests pass against a live Redis instance supporting TS.READ (or the run clearly reports why that is unavailable), Task 2''s checkboxes are checked in the plan file, and the commit from Step 5 exists' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'TS.READ Task 3: regression check + lint & review'.
			t prompt: 'Open doc/plans/2026-09-07-ts-read-implementation.md in this repository and follow Task 3 ("Full-package regression check + lint") exactly: run mcp__smalltalk-interop__run_package_test for RediStick-TimeSeries-Tests and confirm 0 failures/0 errors across all classes in the package, including the pre-existing classes and the new RsTsReadOptionsTest plus the new testTsRead* methods added to RsTsTest in Tasks 1-2. If the live Redis instance does not support TS.READ (pre-8.10 RedisTimeSeries), report that explicitly rather than claiming a false pass. Then run mcp__smalltalk-validator__lint_tonel_smalltalk_from_file on every file created or modified across Tasks 1-2 (RsTsReadOptions.class.st, RsTsReadOptionsTest.class.st, RsRedisEndpoint.extension.st, RsTsTest.class.st). Also consult the smalltalk-dev:smalltalk-developer skill''s style guide section and the st-lint skill for the project''s Tonel style conventions, and fix any issues either tool reports, re-running the affected class test after each fix. If any fixes were needed, commit them as instructed in Step 3 of Task 3 ("Fix lint findings in TS.READ implementation"); if nothing needed fixing, skip that commit (no empty commits) as the plan says. Finally, per Step 4, check CLAUDE.local.md''s TODO sections for a line referencing kanban issue 1788748958227-ts-read-コマンド対応 and mark it done if tracked there (this file is not checked into git, so this step does not require a commit). Check off Task 3''s "- [ ]" boxes in the plan file as you complete them.'.
			t goal: 'RediStick-TimeSeries-Tests package test run reports 0 failures/0 errors across all listed classes (or clearly reports why TS.READ could not be exercised), lint has been run on every file touched in Tasks 1-2 with all findings fixed, Task 3''s checkboxes are checked in the plan file, and (only if fixes were needed) a lint-fix commit exists' ]
	} agentBy: [ :a | a claude ] ].

script forkRunThen: [ :orc | Transcript crShow: 'TS.READ orchestration done: ' , orc result ]
	onTimeout: [ :timeoutStep :ex | Transcript crShow: 'TS.READ orchestration timed out at: ' , timeoutStep printString ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval.
`forkRunThen:onTimeout:` runs the orchestration in the background and returns immediately — watch
for the completion block's own report (via `Transcript`), the `onTimeout:` block's report if a step
stalls, or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration
script id>` (the id is the value `script register` returns/returned by the last line above).
