# Feature: Redis Function API — Phase 3 (Control & Administrative) + Phase 4 (Persistence & Backup)

## Goal

Complete the RediStick Redis Function support (`CLAUDE.local.md`, "TODO Redis Function 対応") by implementing:

- **Phase 3 — Control & Administrative API**: `FUNCTION STATS`, `FUNCTION KILL`, `FUNCTION FLUSH` via new `RsRedisEndpoint` methods `functionStats`, `functionKill`, `functionFlush`, `functionFlushAsync`, `functionFlushSync`, and a new wrapper class `RsFunctionStats`.
- **Phase 4 — Persistence & Backup API**: `FUNCTION DUMP`, `FUNCTION RESTORE` via new `RsRedisEndpoint` methods `functionDump`, `functionRestore:`, `functionRestore:mode:`, `functionRestore:using:`, and a new options class `RsFunctionRestoreOptions`.

Both phases follow the design conventions already established by Phase 1 (`fCall:`/`fCallRo:`) and Phase 2 (`functionLoad:`, `functionList`, `functionDelete:`) in `src/RediStick-Function/`, and by the sibling `RediStick-TimeSeries` package: Options-pattern classes for command parameters, dedicated wrapper classes for complex replies, TDD with SUnit tests in `src/RediStick-Function-Tests/`.

Done means: all new methods and classes exist, `RsFunctionTest` (and any new test classes) pass in full, changed Tonel files are lint-clean per the project's `st-lint` skill, and `CLAUDE.local.md`'s Phase 3 / Phase 4 checkboxes are marked `[x] DONE`.

## Orchestration Shape

Sequential: plan → implement Phase 3 (TDD) → test Phase 3 → implement Phase 4 (TDD) → test Phase 4 → lint & review, all via claude. Each phase is its own `seq:` block so a retry stays local to that step.

## Working Directory

`/home/mumez/git/RediStick` (current branch: `feature/redis-function`, working tree clean at start)

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

	builder seq: {
		builder topicBy: [ :t |
			t title: 'Plan Redis Function Phase 3 & 4'.
			t prompt: 'You are working in the RediStick Pharo Smalltalk repository (Redis client), on git branch feature/redis-function. Read CLAUDE.local.md at the repo root for the full "TODO Redis Function 対応" spec — Phase 1 (FCALL/FCALL_RO) and Phase 2 (FUNCTION LOAD/LIST/DELETE) are already done; Phase 3 and Phase 4 are TODO.

Also read the existing implementation to learn the established conventions before planning anything:
- src/RediStick-Function/RsRedisEndpoint.extension.st (existing fCall:/functionLoad:/functionList methods)
- src/RediStick-Function/RsFunctionListOptions.class.st (Options-pattern example)
- src/RediStick-Function/RsFunctionLibraryInfo.class.st and RsFunctionInfo.class.st (wrapper-class pattern with #fromArrayOrDictionary:/#fromDictionary:)
- src/RediStick-Function-Tests/RsFunctionTestCase.class.st and RsFunctionTest.class.st (test base class and test conventions)
- RsRedisEndpoint >> #rawUnifiedCommand: in src/RediStick-Core/RsRedisEndpoint.class.st (binary-safe command sending, used previously for VEMB ... RAW — relevant for FUNCTION DUMP/RESTORE which carry binary payloads)

Produce a concrete design plan (no code yet) covering:

Phase 3 (Control & Administrative API):
- functionStats: sends "FUNCTION STATS" and returns a new RsFunctionStats wrapper class. Redis reply shape is a flat array/dict with keys "running_script" (nil, or details when a script is executing) and "engines" (map of engine name -> {libraries_count, functions_count}). Design RsFunctionStats with accessors runningScript / engines (or similar), following the #fromArrayOrDictionary:/#fromDictionary: pattern used by RsFunctionLibraryInfo.
- functionKill: sends "FUNCTION KILL", returns the simple status reply as-is (mirrors how other simple-status commands are handled elsewhere in RsRedisEndpoint — check an example like functionDelete: or a core command).
- functionFlush / functionFlushAsync / functionFlushSync: send "FUNCTION FLUSH" with no policy / "ASYNC" / "SYNC" respectively.

Phase 4 (Persistence & Backup API):
- functionDump: sends "FUNCTION DUMP" and must return the binary payload safely — use the #rawUnifiedCommand: pattern (or explain why not) since the payload is not valid UTF-8 in general.
- functionRestore: aPayload — sends "FUNCTION RESTORE" with the given payload, default policy.
- functionRestore:mode: aPayload policySymbolOrString — sends "FUNCTION RESTORE" with an explicit policy (APPEND/FLUSH/REPLACE).
- functionRestore:using: aBlock — Options-pattern entry point taking a new RsFunctionRestoreOptions instance (policy accessor at minimum), mirroring how functionListUsing: works with RsFunctionListOptions.
- Note: FUNCTION RESTORE also needs to send the payload as a raw/binary-safe argument on the way out, not just on the way in — check how the command-sending side of RsRedisEndpoint handles ByteArray/binary arguments today and design accordingly (may need a raw-argument variant of unifiedCommand: sending, or reuse of an existing mechanism).

Write the plan as a concise structured summary (method signatures, class shapes, and how binary safety is handled for DUMP/RESTORE) so the next steps can implement directly from it. Do not write any code or tests yet — this is planning only.' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'Implement Phase 3: Control & Administrative API'.
			t prompt: 'Using the plan from the previous step, implement Phase 3 of the Redis Function API in the RediStick repository (git branch feature/redis-function) with TDD:

1. Write failing SUnit tests first in src/RediStick-Function-Tests/RsFunctionTest.class.st (add test methods) for functionStats, functionKill, functionFlush, functionFlushAsync, functionFlushSync. Use RsFunctionTestCase (see #loadTestLibrary / #loadTestLibraryRo helpers) as the base — it already tears down with FUNCTION FLUSH SYNC. For functionKill, note Redis returns an error ("NOTBUSY No scripts in execution") when no script is running — assert on that behavior rather than assuming success, since there is no long-running script to kill in a unit test context.
2. Add a new class src/RediStick-Function/RsFunctionStats.class.st (Tonel format, following the header-comment + Class{} + method-category conventions used by RsFunctionLibraryInfo.class.st) with a class-side #fromArrayOrDictionary: or #fromDictionary: constructor, parsing the "running_script" and "engines" keys from the FUNCTION STATS reply.
3. Add the functionStats, functionKill, functionFlush, functionFlushAsync, functionFlushSync methods to src/RediStick-Function/RsRedisEndpoint.extension.st, in the same style as the existing methods there (category tags, private helper split for shared logic like the existing #fCall:command:keys:args:).
4. Import the changed packages (RediStick-Function, RediStick-Function-Tests) via the smalltalk-interop MCP tool or st-import skill, then run RsFunctionTest via the smalltalk-interop run_class_test tool or st-test skill, and iterate until all Phase 3 tests pass.

Follow the "Common Pitfalls" and "Best Practices for Code Modification" sections of CLAUDE.md at the repo root (declare eval variables, avoid broad find/replace, reimport after Tonel changes, use smalltalk-interop for precise method inspection).'.
			t goal: 'RsFunctionStats class exists, functionStats/functionKill/functionFlush/functionFlushAsync/functionFlushSync are implemented on RsRedisEndpoint, and all new Phase 3 tests in RsFunctionTest pass' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'Verify Phase 3 tests'.
			t prompt: 'In the RediStick repository, reimport the RediStick-Function and RediStick-Function-Tests packages (in case the previous step left the image out of sync with the Tonel files on disk) using the smalltalk-interop MCP import_package tool or the st-import skill, then run the full RsFunctionTest suite using the smalltalk-interop run_class_test tool or the st-test skill. Report the pass/fail counts explicitly. If anything fails, fix the implementation or the test (staying within the Phase 3 scope: functionStats, functionKill, functionFlush, functionFlushAsync, functionFlushSync, RsFunctionStats) and rerun until the whole suite is green. Do not modify unrelated tests.' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'Implement Phase 4: Persistence & Backup API'.
			t prompt: 'Using the plan from the earlier planning step, and now that Phase 3 (functionStats/functionKill/functionFlush*) is implemented and green, implement Phase 4 of the Redis Function API in the RediStick repository (git branch feature/redis-function) with TDD:

1. Write failing SUnit tests first in src/RediStick-Function-Tests/RsFunctionTest.class.st for functionDump, functionRestore:, functionRestore:mode:, functionRestore:using:. A realistic round-trip test: load a test library (see RsFunctionTestCase #loadTestLibrary), call functionDump to get the payload, delete/flush the library, then call functionRestore: (or functionRestore:mode: with policy FLUSH/REPLACE/APPEND) to restore it, and verify the library/functions are present again via functionList.
2. Add a new options class src/RediStick-Function/RsFunctionRestoreOptions.class.st (Tonel format, matching the header-comment + Class{} + method-category conventions of RsFunctionListOptions.class.st) holding at least a policy accessor (APPEND/FLUSH/REPLACE) with an #asArray-style conversion method.
3. Add functionDump, functionRestore:, functionRestore:mode:, functionRestore:using: to src/RediStick-Function/RsRedisEndpoint.extension.st. functionDump must return the payload without UTF-8 corruption — inspect and reuse the existing #rawUnifiedCommand: / #parseReplyRaw binary-safe reply handling in src/RediStick-Core/RsRedisEndpoint.class.st (used previously for VEMB ... RAW), or add an analogous raw path if the existing one does not fit. functionRestore: must also send the payload as a binary-safe outgoing argument — check how the command-sending side serializes ByteArray/binary arguments and reuse or extend that mechanism; do not assume a String round-trip is safe for arbitrary binary payloads.
4. Import the changed packages via smalltalk-interop / st-import, run RsFunctionTest via smalltalk-interop run_class_test or st-test, and iterate until all Phase 4 tests pass.

Follow the "Common Pitfalls" and "Best Practices for Code Modification" sections of CLAUDE.md at the repo root.'.
			t goal: 'RsFunctionRestoreOptions class exists, functionDump/functionRestore:/functionRestore:mode:/functionRestore:using: are implemented on RsRedisEndpoint with binary-safe payload handling, and all new Phase 4 tests in RsFunctionTest pass' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'Verify Phase 4 tests'.
			t prompt: 'In the RediStick repository, reimport the RediStick-Function and RediStick-Function-Tests packages using the smalltalk-interop MCP import_package tool or the st-import skill, then run the full RsFunctionTest suite (all tests, not just Phase 4) using the smalltalk-interop run_class_test tool or the st-test skill. Report the pass/fail counts explicitly, confirming both Phase 3 and Phase 4 tests are green together. If anything fails, fix the implementation or the test (staying within the Phase 4 scope: functionDump, functionRestore:, functionRestore:mode:, functionRestore:using:, RsFunctionRestoreOptions) and rerun until the whole suite is green. Do not modify unrelated tests.' ]
	} agentBy: [ :a | a claude ].

	builder seq: {
		builder topicBy: [ :t |
			t title: 'Lint and review Phase 3 & 4 changes'.
			t prompt: 'In the RediStick repository (branch feature/redis-function), review all files changed for the Redis Function Phase 3 (Control & Administrative API) and Phase 4 (Persistence & Backup API) work: use "git diff" / "git status" against origin/feature/redis-function or the prior committed state to find them — expect changes under src/RediStick-Function/ and src/RediStick-Function-Tests/.

1. Run the st-lint skill (or the smalltalk-validator MCP validate_tonel_smalltalk_from_text / lint_tonel_smalltalk_from_file tools) against every changed Tonel .st file and fix any reported issues.
2. Consult the smalltalk-developer skill''s style guide section and check the changed code against it (method categorization, class comments in CRC format, naming conventions consistent with existing Phase 1/2 code).
3. Re-run the RsFunctionTest suite after any fixes (via smalltalk-interop run_class_test or st-test) to confirm everything still passes.
4. Update CLAUDE.local.md at the repo root: change the Phase 3 and Phase 4 checkboxes from "[ ] ... [TODO]" to "[x] ... [DONE]", and add a short status/test-count note under each phase in the same style as the existing Phase 1/2 entries (do not touch the unrelated "TODO Vector Sets API実装" section).

Report a summary of what was fixed and the final test pass count.' ]
	} agentBy: [ :a | a claude ].
].
script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:` runs the orchestration in the background and returns immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript), or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
