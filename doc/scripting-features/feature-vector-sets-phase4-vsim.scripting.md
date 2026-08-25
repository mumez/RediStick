# Feature: Vector Sets API — Phase 4 (VSIM)

## Goal

Implement Redis Vector Set similarity search in RediStick per the "Phase 4 — VSIM
(similarity search)" section of `doc/plans/2026-08-14-vector-sets-implementation.md`:

- `RsVectorSetSimQuery` — value object for the query subject (`element:`, `values:`).
- `RsVectorSetSimOptions` — `withScores`, `withAttribs`, `count:`, `ef:`, `filter:`,
  `filterEf:`, `truth`, `noThread`, with `asArray` emitting VSIM tokens in protocol
  order.
- `RsVectorSetSimResult` — one reply row (`element`, `score`, `attribs`).
- `RsRedisEndpoint >> vSim:queryBy:using:` (the plan's endpoint method spelling uses
  `queryBy:`, matching the `rangeBy:` idiom already used by `RediStick-TimeSeries`'s
  `tsRange:rangeBy:using:`).

Phases 0–3 (scaffolding, `VADD`, `VCARD`/`VDIM`/`VEMB`/`VREM`/`VINFO`,
`VGETATTR`/`VSETATTR`) are already implemented and merged — do not redo them, only
build on top via `vAdd:element:vector:using:` to seed data for VSIM tests.

Done means: `RsVectorSetSimQuery`, `RsVectorSetSimOptions`, `RsVectorSetSimResult`,
and `vSim:queryBy:using:` exist per the plan, TDD was followed (failing test first),
`RediStick-VectorSet-Tests` passes in full, and the changed Tonel files are lint-clean
per this project's style guide.

## Orchestration Shape

Sequential, single agent (claude) throughout: implement (TDD) → test verification →
lint & review. Each step is its own `seq:` block so a retry stays local to that step;
results chain forward automatically between blocks. The orchestration's step wait
timeout is raised to 1200s (20 min) since the lint & review step has a history of
running long enough to hit the 900s default.

## Working Directory

`/home/mumez/git/RediStick`

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 4: implement VSIM (TDD)'.
            t prompt: 'You are working in the RediStick Pharo Smalltalk repo (Redis client). Read doc/plans/2026-08-14-vector-sets-implementation.md in full, focusing on the "Phase 4 — VSIM (similarity search)" section, and also read CLAUDE.md and CLAUDE.local.md for project conventions.

Phases 0-3 are already implemented and merged in RediStick-VectorSet / RediStick-VectorSet-Tests: RsVectorSetAddOptions + vAdd:element:vector:using: (Phase 1), vCard:/vDim:/vEmb:element:/vEmb:element:raw:/vRem:element:/vInfo: (Phase 2), vGetAttr:element:/vSetAttr:element:value: (Phase 3). RsVectorSetTestCase (subclass of RsRedisTestCase) already provides fixture vectors sampleVectorA/sampleVectorB/sampleVectorC (sampleVectorA and sampleVectorB are close to each other; sampleVectorC is far from both), useful for asserting deterministic nearest-neighbor ordering in VSIM tests. Do not redo any of this — only build on top of it.

Look at src/RediStick-VectorSet/RsRedisEndpoint.extension.st for the existing vAdd:/vCard:/vEmb:/vInfo:/vGetAttr:/vSetAttr: implementations (argument building via unifiedCommand:, result parsing style) to match conventions, and at src/RediStick-TimeSeries/RsRedisEndpoint.extension.st''s tsRange:rangeBy:using: / tsExecuteRange:key:rangeBy:aggregationBy:using: for the "query subject value object passed into a block" idiom that VSIM''s queryBy: should follow.

Implement Phase 4 exactly as scoped by the plan, following strict TDD (write a failing SUnit test first, then implement, then rerun to confirm green), one task at a time:

1. Before writing code, use mcp__smalltalk-interop__eval to round-trip raw VSIM commands against the live Redis instance (test db via RsRedisTestCase dbIndex, seeding with vAdd:element:vector:using: using the fixture vectors) to confirm exact reply shapes for the bare form, WITHSCORES, WITHATTRIBS, and combined WITHSCORES+WITHATTRIBS, per the plan''s Sequencing Notes caution about VSIM being a newer, less-documented command.
2. Add RsVectorSetSimQuery to RediStick-VectorSet — a small value object with element: and values: (Collection of numbers) setters/accessors representing the VSIM query subject (ELE element | VALUES num val1 val2 ...; FP32 is out of scope, deferred like in VADD).
3. Add RsVectorSetSimOptions to RediStick-VectorSet — instance vars withScores (flag), withAttribs (flag), count, ef, filter (raw filter-expression string), filterEf, truth (flag), noThread (flag), with an asArray method emitting VSIM option tokens (WITHSCORES, WITHATTRIBS, COUNT num, EF num, FILTER expr, FILTER-EF num, TRUTH, NOTHREAD) in protocol order, empty array when nothing is set.
4. Add RsVectorSetSimResult to RediStick-VectorSet — one reply row wrapping element (String), score (nil unless WITHSCORES), attribs (nil unless WITHATTRIBS; parse via STON fromString: like vGetAttr:element: already does).
5. Add RsRedisEndpoint >> vSim:queryBy:using: (in RsRedisEndpoint.extension.st inside RediStick-VectorSet) that builds the VSIM command from the query subject (ELE vs VALUES) and options, parses the reply into an Array of RsVectorSetSimResult (always, per the plan''s "likely always return RsVectorSetSimResult array for consistency" guidance — score/attribs simply nil when not requested), and add a vSim:queryBy: convenience variant with a nil options block.
6. Write RsVectorSetSimTest (or extend RsVectorSetTest, whichever matches existing file organization) in RediStick-VectorSet-Tests covering: search by ELE, search by VALUES, COUNT limiting, WITHSCORES, WITHATTRIBS, FILTER expression, and combined options. Seed a small set (using sampleVectorA/B/C) so nearest-neighbor ordering is deterministic enough to assert on.

Use the smalltalk-interop and smalltalk-validator MCP tools (validate Tonel files after edits, import packages, run tests) throughout, matching the workflow documented in CLAUDE.md. Commit your work with git once Phase 4 is complete and tests pass, using a concise commit message describing the VSIM implementation.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 4: run and verify tests'.
            t prompt: 'Re-import RediStick-VectorSet and RediStick-VectorSet-Tests packages (mcp__smalltalk-interop__import_package) to make sure the running image reflects the latest Tonel files from the previous step, then run mcp__smalltalk-interop__run_package_test on RediStick-VectorSet-Tests (or run_class_test on the specific VSIM test class). Report the pass/fail counts, covering the full suite (Phases 1-4 together), not just the new VSIM tests. If anything fails, fix the production code or test code (staying within the Phase 4 VSIM scope only — do not touch unrelated packages or earlier phases'' passing tests) and rerun until the full RediStick-VectorSet-Tests suite passes.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Vector Sets Phase 4: lint & review'.
            t prompt: 'Use the st-lint skill (or the smalltalk-validator MCP tools, e.g. lint_tonel_smalltalk_from_file) against every Tonel file changed for Phase 4 in RediStick-VectorSet and RediStick-VectorSet-Tests. Also consult the smalltalk-developer skill''s style guide section and check the changed code against it (method categorization, naming conventions, CRC-style class comments where appropriate). Also do a quick naming-consistency check against the existing Phase 1-3 methods (vAdd:/vCard:/vDim:/vEmb:/vRem:/vInfo:/vGetAttr:/vSetAttr: prefix, using: block idiom) to confirm vSim:queryBy:using: fits the established pattern. Fix everything you find, reimport the affected packages, and rerun the RediStick-VectorSet-Tests suite to confirm it is still green after your fixes.'.
            t goal: 'lint clean and style-guide issues fixed for all Phase 4 Vector Set files, full test suite still passing' ]
    } agentBy: [ :a | a claude ] ].

script settings orchestrationStepWaitTimeoutSeconds: 1200.
script forkRunThen: [ :orc | Transcript crShow: 'Vector Sets Phase 4 orchestration done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via
st-eval. `forkRunThen:` runs the orchestration in the background and returns
immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript),
or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration
script id>`.
