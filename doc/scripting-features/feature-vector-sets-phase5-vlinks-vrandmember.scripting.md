# Feature: Vector Sets API — Phase 5 (VLINKS, VRANDMEMBER)

## Goal

Implement `VLINKS` and `VRANDMEMBER` in RediStick per the "Phase 5 — VLINKS,
VRANDMEMBER" section of `doc/plans/2026-08-14-vector-sets-implementation.md`:

- `RsRedisEndpoint >> vLinks: key element: element` → `Array` of element-name Strings
  (HNSW graph neighbors).
- `RsRedisEndpoint >> vLinks: key element: element withScores: true` → `Array` of
  `Association`s (element -> score), consistent with how `tsGet:` already returns an
  `Association` in `RediStick-TimeSeries`.
- `RsRedisEndpoint >> vRandMember: key` → single element `String`, or `nil` if the set
  is empty/absent.
- `RsRedisEndpoint >> vRandMember: key count: n` → `Array` of Strings (Redis semantics
  pass through as-is: positive count = up to n distinct elements, negative count = n
  elements with possible repeats — document this, don't reimplement it).

Per the plan, both commands are simple enough not to need new value classes. Phases
0-4 (scaffolding, `VADD`, `VCARD`/`VDIM`/`VEMB`/`VREM`/`VINFO`,
`VGETATTR`/`VSETATTR`, `VSIM`) are already implemented and merged — do not redo them,
only build on top via `vAdd:element:vector:using:` to seed data for these tests.

Done means: `vLinks:element:`, `vLinks:element:withScores:`, `vRandMember:`, and
`vRandMember:count:` exist per the plan, TDD was followed (failing test first),
`RediStick-VectorSet-Tests` passes in full, and the changed Tonel files are lint-clean
per this project's style guide.

## Orchestration Shape

Sequential, single agent (claude) throughout: implement (TDD) → test verification →
lint & review. Each step is its own `seq:` block so a retry stays local to that step;
results chain forward automatically between blocks. The orchestration's step wait
timeout is raised to 1200s (20 min), matching the Phase 4 script, since the lint &
review step has a history of running long enough to hit the 900s default.

## Working Directory

`/home/mumez/git/RediStick`

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 5: implement VLINKS/VRANDMEMBER (TDD)'.
            t prompt: 'You are working in the RediStick Pharo Smalltalk repo (Redis client). Read doc/plans/2026-08-14-vector-sets-implementation.md in full, focusing on the "Phase 5 — VLINKS, VRANDMEMBER" section, and also read CLAUDE.md and CLAUDE.local.md for project conventions.

Phases 0-4 are already implemented and merged in RediStick-VectorSet / RediStick-VectorSet-Tests: RsVectorSetAddOptions + vAdd:element:vector:using: (Phase 1), vCard:/vDim:/vEmb:element:/vEmb:element:raw:/vRem:element:/vInfo: (Phase 2), vGetAttr:element:/vSetAttr:element:value: (Phase 3), RsVectorSetSimQuery/RsVectorSetSimOptions/RsVectorSetSimResult + vSim:queryBy:/vSim:queryBy:using: (Phase 4). RsVectorSetTestCase (subclass of RsRedisTestCase) already provides fixture vectors sampleVectorA/sampleVectorB/sampleVectorC. Do not redo any of this — only build on top of it.

Look at src/RediStick-VectorSet/RsRedisEndpoint.extension.st for the existing vAdd:/vCard:/vEmb:/vInfo:/vGetAttr:/vSetAttr:/vSim: implementations (argument building via unifiedCommand:, result parsing style) to match conventions, and at src/RediStick-TimeSeries/RsRedisEndpoint.extension.st''s tsGet:latest: for the precedent of returning an Association (element -> score) for a "value with optional score" reply shape, which vLinks:element:withScores: should follow.

Implement Phase 5 exactly as scoped by the plan, following strict TDD (write a failing SUnit test first, then implement, then rerun to confirm green), one task at a time:

1. Before writing code, use mcp__smalltalk-interop__eval to round-trip raw VLINKS and VRANDMEMBER commands against the live Redis instance (test db via RsRedisTestCase dbIndex, seeding with vAdd:element:vector:using: using the fixture vectors) to confirm exact reply shapes: VLINKS without WITHSCORES (flat array of element names, possibly nested per HNSW layer — check carefully), VLINKS WITHSCORES (element/score pairs), VRANDMEMBER with no count (single element or nil), and VRANDMEMBER with a count (array, including behavior for positive vs negative counts and for a nonexistent key).
2. Add RsRedisEndpoint >> vLinks: key element: element — returns an Array of element-name Strings (no value class needed, per the plan).
3. Add RsRedisEndpoint >> vLinks: key element: element withScores: aBoolean — when true, returns an Array of Associations (element -> score); when false, delegates to vLinks:element:.
4. Add RsRedisEndpoint >> vRandMember: key — returns a single element String, or nil if the set is empty or the key does not exist.
5. Add RsRedisEndpoint >> vRandMember: key count: n — returns an Array of Strings, passing n through to VRANDMEMBER as-is (positive = up to n distinct elements, negative = n elements with possible repeats); do not reimplement Redis''s sampling semantics, just document them in a one-line comment.
6. Write tests in RsVectorSetTest (matching existing file organization for this package) covering: VLINKS on a populated set (with and without scores), VRANDMEMBER single-element form, VRANDMEMBER with a positive count, VRANDMEMBER with a negative count, and the edge case of VLINKS/VRANDMEMBER on an empty or absent key.

Use the smalltalk-interop and smalltalk-validator MCP tools (validate Tonel files after edits, import packages, run tests) throughout, matching the workflow documented in CLAUDE.md. Commit your work with git once Phase 5 is complete and tests pass, using a concise commit message describing the VLINKS/VRANDMEMBER implementation.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 5: run and verify tests'.
            t prompt: 'Re-import RediStick-VectorSet and RediStick-VectorSet-Tests packages (mcp__smalltalk-interop__import_package) to make sure the running image reflects the latest Tonel files from the previous step, then run mcp__smalltalk-interop__run_package_test on RediStick-VectorSet-Tests. Report the pass/fail counts, covering the full suite (Phases 1-5 together), not just the new VLINKS/VRANDMEMBER tests. If anything fails, fix the production code or test code (staying within the Phase 5 scope only — do not touch unrelated packages or earlier phases'' passing tests) and rerun until the full RediStick-VectorSet-Tests suite passes.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 5: lint & review'.
            t prompt: 'Use the st-lint skill (or the smalltalk-validator MCP tools, e.g. lint_tonel_smalltalk_from_file) against every Tonel file changed for Phase 5 in RediStick-VectorSet and RediStick-VectorSet-Tests. Also consult the smalltalk-developer skill''s style guide section and check the changed code against it (method categorization, naming conventions, CRC-style class comments where appropriate). Also do a quick naming-consistency check against the existing Phase 1-4 methods (vAdd:/vCard:/vDim:/vEmb:/vRem:/vInfo:/vGetAttr:/vSetAttr:/vSim: prefix, using: block idiom where applicable) to confirm vLinks:element:/vLinks:element:withScores:/vRandMember:/vRandMember:count: fit the established pattern. Fix everything you find, reimport the affected packages, and rerun the RediStick-VectorSet-Tests suite to confirm it is still green after your fixes.'.
            t goal: 'lint clean and style-guide issues fixed for all Phase 5 Vector Set files, full test suite still passing' ]
    } agentBy: [ :a | a claude ] ].

script settings orchestrationStepWaitTimeoutSeconds: 1200.
script forkRunThen: [ :orc | Transcript crShow: 'Vector Sets Phase 5 orchestration done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via
st-eval. `forkRunThen:` runs the orchestration in the background and returns
immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript),
or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration
script id>`.
