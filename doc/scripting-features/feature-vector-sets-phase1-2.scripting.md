# Feature: Vector Sets API — Phase 1 & Phase 2

## Goal

Implement Redis Vector Set support in RediStick through Phase 2 of the plan in
`doc/plans/2026-08-14-vector-sets-implementation.md`:

- **Phase 1** — `VADD` (write path): `RsVectorSetAddOptions` + `RsRedisEndpoint >>
  vAdd:element:vector:using:`.
- **Phase 2** — core read/write: `VCARD`, `VDIM`, `VEMB`, `VREM`, `VINFO` on
  `RsRedisEndpoint` (`vCard:`, `vDim:`, `vEmb:element:`, `vEmb:element:raw:`,
  `vRem:element:`, `vInfo:`).

Phase 0 (package scaffolding: `RediStick-VectorSet`, `RediStick-VectorSet-Tests`,
`RsVectorSetTestCase`, Metacello groups, `.smalltalk.ston`) is already done — do not
redo it, only extend it.

Done means: both phases' production code and tests exist per the plan, TDD was
followed (failing test first), `RediStick-VectorSet-Tests` passes in full, and the
changed Tonel files are lint-clean per this project's style guide.

## Orchestration Shape

Sequential, single agent (claude) throughout: Phase 1 implement (TDD) → Phase 1 test
verification → Phase 1 lint & review → Phase 2 implement (TDD) → Phase 2 test
verification → Phase 2 lint & review. Each phase step is its own `seq:` block so a
retry stays local to that step; results chain forward automatically between blocks.

## Working Directory

`/home/mumez/git/RediStick`

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 1: implement VADD (TDD)'.
            t prompt: 'You are working in the RediStick Pharo Smalltalk repo (Redis client). Read doc/plans/2026-08-14-vector-sets-implementation.md in full, focusing on the "Phase 1 — VADD (write path)" section, and also read CLAUDE.md and CLAUDE.local.md for project conventions. Phase 0 scaffolding is already done: RediStick-VectorSet and RediStick-VectorSet-Tests packages exist with package.st files, and RsVectorSetTestCase (subclass of RsRedisTestCase) already exists in RediStick-VectorSet-Tests with sample fixture vectors. Do not redo Phase 0 — extend it.

Implement Phase 1 exactly as scoped by the plan, following strict TDD (write a failing SUnit test first, then implement, then rerun to confirm green), one task at a time:

1. Add RsVectorSetAddOptions to RediStick-VectorSet — instance vars for reduceDim, cas (flag), quantization (#noQuant/#q8/#bin/nil), ef, setAttr (accepts a Smalltalk object or JSON string; convert Smalltalk objects to JSON via NeoJSONWriter since RediStick-VectorSet must not hard-depend on RediStick-Json), and m (numlinks). Implement asArray to emit VADD argument tokens in the exact order Redis expects (REDUCE dim, then FP32/VALUES+vector, then CAS, then NOQUANT/Q8/BIN, then EF, then SETATTR, then M), returning an empty array when nothing is set beyond the vector.
2. Add RsRedisEndpoint >> vAdd:element:vector:using: (in a RsRedisEndpoint.extension.st file inside RediStick-VectorSet) that accepts a plain Collection of numbers for the vector (sent as VALUES n v1 v2 ...) and returns a Boolean (Redis replies 1/0 for added vs updated-only-attrs).
3. Before writing the options/endpoint code, use mcp__smalltalk-interop__eval to round-trip raw VADD commands against the live Redis instance (test db via RsRedisTestCase dbIndex) and confirm exact reply semantics and quantization token spelling, per the plan cautionary note under "Sequencing Notes". Do this via the running RsRediStick connection, not assumptions.
4. Write RsVectorSetTest (in RediStick-VectorSet-Tests) covering: RsVectorSetAddOptions argument-building (no Redis needed) plus integration tests for vAdd:element:vector:using: — add without options, add with REDUCE, add with CAS, add with each quantization variant, add with SETATTR, add with M/EF, and re-adding the same element (update path).

Use the smalltalk-interop and smalltalk-validator MCP tools (validate Tonel files after edits, import packages, run tests) throughout, matching the workflow documented in CLAUDE.md. Commit your work with git once Phase 1 is complete and tests pass, using a concise commit message describing the VADD implementation.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 1: run and verify tests'.
            t prompt: 'Re-import RediStick-VectorSet and RediStick-VectorSet-Tests packages (mcp__smalltalk-interop__import_package) to make sure the running image reflects the latest Tonel files from the previous step, then run mcp__smalltalk-interop__run_package_test on RediStick-VectorSet-Tests (or run_class_test on RsVectorSetTest specifically). Report the pass/fail counts. If anything fails, fix the production code or test code (staying within the Phase 1 VADD scope only — do not touch unrelated packages) and rerun until the full RediStick-VectorSet-Tests suite passes.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 1: lint & review'.
            t prompt: 'Use the st-lint skill (or the smalltalk-validator MCP tools, e.g. lint_tonel_smalltalk_from_file) against every Tonel file changed for Phase 1 in RediStick-VectorSet and RediStick-VectorSet-Tests. Also consult the smalltalk-developer skill''s style guide section and check the changed code against it (method categorization, naming conventions, CRC-style class comments where appropriate). Fix everything you find, reimport the affected packages, and rerun the RediStick-VectorSet-Tests suite to confirm it is still green after your fixes.'.
            t goal: 'lint clean and style-guide issues fixed for all Phase 1 Vector Set files' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 2: implement VCARD/VDIM/VEMB/VREM/VINFO (TDD)'.
            t prompt: 'Continuing work in the RediStick repo on Vector Sets. Re-read the "Phase 2 — Core read/write: VCARD, VDIM, VEMB, VREM, VINFO" section of doc/plans/2026-08-14-vector-sets-implementation.md. Phase 1 (VADD, RsVectorSetAddOptions, vAdd:element:vector:using:) is already implemented and tested — use it to seed data for Phase 2''s integration tests.

Implement Phase 2 exactly as scoped, following strict TDD (failing test first, then implement, then confirm green), one task at a time:

1. Before writing code, use mcp__smalltalk-interop__eval to round-trip raw VCARD/VDIM/VEMB/VREM/VINFO commands against the live Redis instance (test db via RsRedisTestCase dbIndex) to confirm exact reply shapes, especially the VINFO field/value array and VEMB''s RAW vs reconstructed-float-array forms.
2. Add RsRedisEndpoint >> vCard: key, vDim: key, vRem: key element: element to RediStick-VectorSet (RsRedisEndpoint.extension.st).
3. Add vEmb: key element: element (returns an Array of Floats, the reconstructed embedding) and vEmb: key element: element raw: aBoolean (raw quantization-aware form when true).
4. Add vInfo: key. Per the plan, default to returning a Dictionary of the VINFO fields/values (consistent with how tsInfo: works in RediStick-TimeSeries) unless you find VINFO fields that clearly need type conversion or derived accessors — in that case introduce a small RsVectorSetInfo value class instead and document why in a one-line comment. Check RediStick-TimeSeries'' tsInfo: implementation for the precedent before deciding.
5. Extend RsVectorSetTest with integration tests that use vAdd:element:vector:using: from Phase 1 to seed data, then assert: cardinality via vCard:, dimensionality via vDim:, embedding round-trip via vEmb:element: (and the raw: variant), removal via vRem:element: (and that a subsequent vCard:/vEmb:element: reflects the removal), and VINFO field contents via vInfo:.

Use the smalltalk-interop and smalltalk-validator MCP tools throughout. Commit your work with git once Phase 2 is complete and tests pass, using a concise commit message describing the Phase 2 read/write commands.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 2: run and verify tests'.
            t prompt: 'Re-import RediStick-VectorSet and RediStick-VectorSet-Tests packages to make sure the running image reflects the latest Tonel files from the previous step, then run the full RediStick-VectorSet-Tests suite (mcp__smalltalk-interop__run_package_test). Report pass/fail counts covering both Phase 1 and Phase 2 tests together. If anything fails, fix the production or test code (staying within the Phase 1/2 Vector Set scope only) and rerun until the whole suite is green.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 2: lint & review'.
            t prompt: 'Use the st-lint skill (or the smalltalk-validator MCP tools) against every Tonel file changed for Phase 2 in RediStick-VectorSet and RediStick-VectorSet-Tests. Consult the smalltalk-developer skill''s style guide section and check the changed code against it. Fix everything you find, reimport the affected packages, and rerun the full RediStick-VectorSet-Tests suite to confirm it is still green. Finally, do a quick sweep across both Phase 1 and Phase 2 changes for naming consistency (vAdd:/vCard:/vDim:/vEmb:/vRem:/vInfo: prefix, using: block idiom where applicable) and report a short summary of what was implemented and confirmed passing.'.
            t goal: 'lint clean, style-guide issues fixed, and full RediStick-VectorSet-Tests suite passing for Phase 1 and Phase 2' ]
    } agentBy: [ :a | a claude ] ].

script forkRunThen: [ :orc | Transcript crShow: 'Vector Sets Phase 1+2 orchestration done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via
st-eval. `forkRunThen:` runs the orchestration in the background and returns
immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript),
or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration
script id>`.
