# Feature: Add returnRawBytes mode to RsRedisEndpoint

## Goal

When `endpoint shouldReturnRawBytes: true` is set, Redis replies are no longer decoded into
strings and are always processed as if `sendUnifiedCommand:parseWithRaw:` were called with `true`
(i.e. via `parseReplyRaw`). This prevents `get:` from raising a decode error after binary data was
stored with `set:`. Resetting `true` back to `false` is the caller's responsibility. In addition,
provide a convenience method `returnRawBytesWhile:` that enables the mode only for the duration of
a block and reliably restores the previous value afterward via `ensure:`.

Usage sketch:

```smalltalk
endpoint shouldReturnRawBytes: true.
endpoint get: key.
endpoint shouldReturnRawBytes: false.
```

```smalltalk
endpoint returnRawBytesWhile: [
    endpoint get: key.
]. "restored to the previous value via ensure:"
```

Reference implementation location (`src/RediStick-Core/RsRedisEndpoint.class.st`):

- `sendUnifiedCommand:parseWithRaw:` (private commands) — uses `parseReplyRaw` when `aBoolean` is
  true, `parseReply` when false
- `unifiedCommand:` — currently always calls `self sendUnifiedCommand: args parseWithRaw: false`

Chosen design for `unifiedCommand:` (no conditional needed — just forward the flag):

```smalltalk
unifiedCommand: args
	^ self sendUnifiedCommand: args parseWithRaw: self shouldReturnRawBytes
```

## Orchestration Shape

sequential: design → implement (TDD) → run tests → lint & review → update documentation, all
phases via claude

## Working Directory

`/home/mumez/git/RediStick`

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

    "1. Design"
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Design returnRawBytes mode'.
            t prompt: 'Design a "returnRawBytes mode" to add to RediStick (a Redis client for Pharo Smalltalk).

Requirements:
- Add an instance variable `shouldReturnRawBytes` to `RsRedisEndpoint`, with accessors `shouldReturnRawBytes` / `shouldReturnRawBytes:`. Default is false.
- Change `unifiedCommand:` to simply forward the flag instead of branching:
  `unifiedCommand: args` becomes `^ self sendUnifiedCommand: args parseWithRaw: self shouldReturnRawBytes`
  (no `ifTrue:ifFalse:` needed — when `shouldReturnRawBytes` is false this is identical to today''s behavior).
- Add a convenience method `returnRawBytesWhile: aBlock` that temporarily enables the mode, runs the block, and always restores the previous value afterward via `ensure:`.
- Target file is `src/RediStick-Core/RsRedisEndpoint.class.st` (Tonel format). Read the existing `sendUnifiedCommand:parseWithRaw:` (private commands category) and `unifiedCommand:` implementations first before designing.
- Follow the Tonel format and method-category conventions from the smalltalk-developer skill.

Confirm this design (or refine it if a problem is found) and summarize: which method signatures change, which instance variable is added, and how it integrates with the existing parseWithRaw logic. Do not write code yet.' ]
    } agentBy: [ :a | a claude ].

    "2. Implement (TDD)"
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement returnRawBytes mode (TDD)'.
            t prompt: 'Based on the design above, implement the returnRawBytes mode using TDD.

Steps:
1. In the `RediStick-Core-Tests` package (an existing appropriate test class such as `RsRedisEndpointTest`; if none exists, add one following the structure of existing similar test classes), write failing tests first that verify:
   - `shouldReturnRawBytes` defaults to false
   - With `shouldReturnRawBytes: true` set, calling `unifiedCommand:` returns raw (undecoded) results. Concretely: after storing binary data with `set:`, calling `get:` while `shouldReturnRawBytes: true` does not raise an error and returns the correct byte sequence
   - Setting `shouldReturnRawBytes: false` again restores normal decoded-string results
   - `returnRawBytesWhile:` enables true only for the duration of the block and restores the prior value afterward (both on normal completion and on an exception), using `ensure:`
2. Use `st-import` to import and confirm the tests fail.
3. Implement `shouldReturnRawBytes` (instance variable, accessors) and `returnRawBytesWhile:` in `src/RediStick-Core/RsRedisEndpoint.class.st`, modifying `sendUnifiedCommand:parseWithRaw:` or `unifiedCommand:` as needed.
4. Re-import via the `st-import` skill and run tests via the `st-test` skill, confirming they are green.

Follow the existing method-category conventions when editing the Tonel file.' ]
    } agentBy: [ :a | a claude ].

    "3. Run tests"
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Run full test suite'.
            t prompt: 'Using the `st-test` skill (or the smalltalk-interop MCP run_class_test / run_package_test tools), run the full test suite for the `RediStick-Core-Tests` package. Also confirm the returnRawBytes changes have not broken other loaded packages'' tests (e.g. `RediStick-Json-Tests` if loaded); at minimum, confirm the entire Core package test suite is fully green.

If any tests fail, identify the cause, fix the implementation from the previous phase, rerun, and confirm all tests pass before reporting the final pass/fail counts.' ]
    } agentBy: [ :a | a claude ].

    "4. Lint & review"
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Lint and review'.
            t prompt: 'Run lint on the Tonel files changed or added in this task (`src/RediStick-Core/RsRedisEndpoint.class.st` and any added/changed test files) using the st-lint skill (or the smalltalk-validator MCP tools lint_tonel_smalltalk_from_file / validate_tonel_smalltalk_from_file).

Also review the code against the style guide section of the smalltalk-developer skill (category classification, naming conventions, commenting practices, etc.) and fix any issues found (lint errors/warnings, style deviations). After fixing, rerun lint to confirm it is clean, rerun `st-test` to confirm tests are still green, then report the review findings and the fixes made.' ]
    } agentBy: [ :a | a claude ].

    "5. Update documentation"
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Update documentation'.
            t prompt: 'Update documentation to reflect the addition of returnRawBytes mode. Add a concise description to `/home/mumez/git/RediStick/CLAUDE.md` (what the mode is for, how to use `shouldReturnRawBytes:` and `returnRawBytesWhile:`). Insert it into an appropriate existing section covering Core functionality (or a new short section if none fits), without disrupting the structure/format of existing sections such as "Redis JSON Implementation Status".

If the repository has user-facing documentation for Core functionality (e.g. README or a docs file), add usage explanations and example code there too, matching the existing structure and tone. Do not create excessive new documentation files.' ]
    } agentBy: [ :a | a claude ] ].

script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ]
    onTimeout: [ :timeoutStep :ex | Transcript crShow: 'Timed out: ' , timeoutStep printString ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval.
`forkRunThen:onTimeout:` runs the orchestration in the background and returns immediately — watch
for the completion block's own report (e.g. via Transcript), the `onTimeout:` block's report if a
step stalls, or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration
script id>`.
