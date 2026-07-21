# Feature: TS.INCRBY / TS.DECRBY support

## Goal

Add `RsRedisEndpoint` support for the Redis Time Series `TS.INCRBY` and `TS.DECRBY` commands,
following the existing `RediStick-TimeSeries` package conventions (see `TS.ALTER`, `TS.ADD`),
with `TS.DECRBY` implemented on top of shared/reused code rather than duplicating `TS.INCRBY`'s
logic.

## Orchestration Shape

sequential: implement (TDD) → test → lint & review, all via claude

## Script

```Smalltalk
AgenticBrowser runBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement TS.INCRBY / TS.DECRBY (TDD)'.
            t prompt: 'In the Pharo/Tonel project at /home/mumez/git/RediStick, add support for the Redis Time Series commands TS.INCRBY and TS.DECRBY to the RediStick-TimeSeries package (src/RediStick-TimeSeries and src/RediStick-TimeSeries-Tests, Tonel format).

Follow Test-Driven Development: write failing tests first in RsTsTest (src/RediStick-TimeSeries-Tests/RsTsTest.class.st), then implement until they pass. Use the smalltalk-interop MCP eval/import tools (or the st-import / st-test skills) to import and run tests after each change, and the smalltalk-validator MCP tools (or st-validate skill) to validate Tonel syntax before importing.

Background / existing conventions to follow exactly:
- Existing pattern reference: `RsRedisEndpoint >> tsAlter: key using: optionsBlock` and `RsRedisEndpoint >> tsAdd: key timestamp: tsMSecsOrDateTime value: value using: optionsBlock` in src/RediStick-TimeSeries/RsRedisEndpoint.extension.st. Read that whole file plus RsTsOptions.class.st, RsTsCreateOptions.class.st, RsTsAlterOptions.class.st, RsTsAddOptions.class.st before writing any code, to match the existing style (categories, `using: optionsBlock` pattern, private helper methods, `tsAppendLabelsFrom:to:`, `asRediStickUnixTimestampMillis`).
- Real Redis command syntax (verified against the official docs):
  `TS.INCRBY key addend [TIMESTAMP timestamp] [RETENTION retentionPeriod] [ENCODING enc] [CHUNK_SIZE size] [DUPLICATE_POLICY policy] [IGNORE ignoreMaxTimediff ignoreMaxValDiff] [LABELS label value ...]`
  `TS.DECRBY key subtrahend [TIMESTAMP timestamp] [RETENTION retentionPeriod] [ENCODING enc] [CHUNK_SIZE size] [DUPLICATE_POLICY policy] [IGNORE ignoreMaxTimediff ignoreMaxValDiff] [LABELS label value ...]`
  RETENTION/ENCODING/CHUNK_SIZE/DUPLICATE_POLICY/IGNORE/LABELS only take effect when the command creates a new series; they are ignored when adding a sample to an existing series. The reply is the timestamp (integer) of the upserted sample.
- IMPORTANT (DRY): the option set for TS.INCRBY and TS.DECRBY (retention, encoding, chunkSize, duplicatePolicy, ignoreMaxTimediff, ignoreMaxValDiff, labels) is *exactly* the same field set already defined on the existing `RsTsAlterOptions` class (src/RediStick-TimeSeries/RsTsAlterOptions.class.st, which itself extends RsTsCreateOptions extends RsTsOptions and already produces args in the right order: RETENTION, ENCODING, CHUNK_SIZE, DUPLICATE_POLICY, IGNORE). Do NOT create a new options class for INCRBY/DECRBY — reuse `RsTsAlterOptions` directly as the options object for both commands. Labels are appended the same way as elsewhere via the existing private helper `RsRedisEndpoint >> tsAppendLabelsFrom:to:`.
- IMPORTANT (DRY between TS.INCRBY and TS.DECRBY): implement both commands by funneling through one new private helper method on `RsRedisEndpoint`, e.g. `tsIncrOrDecr: cmdName key: key timestamp: tsMSecsOrDateTimeOrNil value: aValue using: optionsBlock` (category `*RediStick-TimeSeries-private`), that builds the args array `{ cmdName. key. aValue }`, appends `TIMESTAMP <millis>` only when the timestamp argument is not nil (use `asRediStickUnixTimestampMillis`; note this differs from TS.ADD — TIMESTAMP is a fully optional flag for INCRBY/DECRBY, not a positional argument, so when nil it should be omitted entirely rather than sent as `*`), then applies `RsTsAlterOptions` + `tsAppendLabelsFrom:to:` exactly like `tsAlter:using:` does, and finally calls `self unifiedCommand: args`.
- Public API surface to add to `RsRedisEndpoint` (category `*RediStick-TimeSeries`), matching the existing base-form/auto-variant pattern used by `tsAdd:`:
  - `tsIncrBy: key increment: addend` (auto timestamp)
  - `tsIncrBy: key increment: addend using: optionsBlock`
  - `tsIncrBy: key timestamp: tsMSecsOrDateTime increment: addend`
  - `tsIncrBy: key timestamp: tsMSecsOrDateTime increment: addend using: optionsBlock` (delegates to the shared private helper with cmdName `'"'"'TS.INCRBY'"'"'`)
  - `tsDecrBy: key decrement: subtrahend`
  - `tsDecrBy: key decrement: subtrahend using: optionsBlock`
  - `tsDecrBy: key timestamp: tsMSecsOrDateTime decrement: subtrahend`
  - `tsDecrBy: key timestamp: tsMSecsOrDateTime decrement: subtrahend using: optionsBlock` (delegates to the shared private helper with cmdName `'"'"'TS.DECRBY'"'"'`)
  Keyword names `increment:`/`decrement:` should mirror the existing `hIncrBy:field:value:` / `zIncrBy:increment:member:` / `jsonNumIncrBy:path:increment:` naming conventions already used elsewhere in the codebase (grep for them first).

Tests to add in RsTsTest (use `RsRedisTestCase dbIndex`, follow existing method naming like `testTsAlterBasic`, `testTsAddWithOptions`):
  - auto-timestamp create-and-increment on a non-existing key (assert the reply is a number and `tsGet:` reflects the incremented value)
  - repeated increments accumulate correctly
  - explicit timestamp form
  - options form exercising retention/labels on a newly created key (similar structure to `testTsAddCreatesKeyWithLabels` / `testTsAlterLabels`)
  - the same coverage mirrored for tsDecrBy (accumulation should subtract, not add)

Also update BaselineOfRediStick and .smalltalk.ston only if they do not already declare the RediStick-TimeSeries / RediStick-TimeSeries-Tests packages and groups (check first — a prior phase already added TS.ALTER, so this is likely already wired up; do not duplicate baseline entries).

When finished, write a short summary of the methods added and confirm all RsTsTest tests pass to result-<topicId>.md.'.
            t goal: 'tsIncrBy: and tsDecrBy: methods (plus base/auto/using: variants) are implemented in RsRedisEndpoint.extension.st reusing RsTsAlterOptions with no new duplicate options class, TS.DECRBY shares implementation with TS.INCRBY via one private helper, new tests exist in RsTsTest for both commands written before the implementation, and all of them pass' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Run full TimeSeries test suite'.
            t prompt: 'In the Pharo/Tonel project at /home/mumez/git/RediStick, using the smalltalk-interop MCP run_class_test tool (or the st-test skill), import the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages fresh and run the full RsTsTest test suite (not just the new TS.INCRBY/TS.DECRBY tests). Report the pass/fail counts. If anything fails, fix the implementation from the previous step (the TS.INCRBY/TS.DECRBY work described above) until the entire RsTsTest suite is green. Write the final pass/fail summary to result-<topicId>.md.'.
            t goal: 'RsTsTest full suite run with results reported, all tests passing' ]
    } agentBy: [ :a | a claude ].
    builder seq: {
        builder topicBy: [ :t |
            t title: 'Lint and style review'.
            t prompt: 'In the Pharo/Tonel project at /home/mumez/git/RediStick, review the Tonel files changed for the TS.INCRBY/TS.DECRBY feature (src/RediStick-TimeSeries/RsRedisEndpoint.extension.st and src/RediStick-TimeSeries-Tests/RsTsTest.class.st, plus any other files touched in the previous steps). Consult the st-lint skill (or the smalltalk-validator MCP lint tools) against these files, and consult the smalltalk-dev:smalltalk-developer skill'"'"'s Tonel style guide section. Fix any lint findings or style-guide deviations you find (naming, method categorization, formatting, etc.), re-import, and re-run RsTsTest to confirm nothing broke. Write a summary of what was checked and fixed to result-<topicId>.md.'.
            t goal: 'lint clean and style-guide issues fixed' ]
    } agentBy: [ :a | a claude ] ].
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval.
