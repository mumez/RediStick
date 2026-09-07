# TS.READ Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`)
> syntax for tracking.

**Goal:** Implement the Redis 8.10 `TS.READ` command (optionally-blocking cursor read of a time
series) in the existing `RediStick-TimeSeries` package, following the Options-pattern design
recorded in `CLAUDE.local.md` and reusing the existing `RsTsRange`/`tsParseRangeSamples:` helpers
rather than duplicating them.

**Architecture:** Add one new options class, `RsTsReadOptions` (`BLOCK milliseconds min_count`,
`MAX_COUNT max_count`), plus new `RsRedisEndpoint` extension methods `tsRead:cursor:` and
`tsRead:cursor:using:`. The cursor argument (`Integer`, `DateAndTime`, or one of the sentinel
strings `'-'`, `'+'`, `'$'`) is normalized via the existing `RsTsRange class >> normalizeTimestamp:`
(String pass-through / `asRediStickUnixTimestampMillis`) — no new cursor class is needed. The reply
shape (`[[ts, val], ...]`) is identical to `TS.RANGE`'s, so the existing private helper
`RsRedisEndpoint >> tsParseRangeSamples:` is reused as-is. Pure option-array-building logic is
unit-tested without Redis (`RsTsReadOptionsTest`); the endpoint methods are integration-tested
against a live Redis in the existing `RsTsTest` class, matching how `TS.RANGE`/`TS.GET` are already
tested there.

**Tech Stack:** Pharo Smalltalk (Tonel `.st` files), SUnit, smalltalk-interop / smalltalk-validator
MCP tools, `RsRedisTestCase` test harness against a live Redis Stack instance (RedisTimeSeries
module, server version 8.10+ for `TS.READ` itself).

## Global Constraints

- Package: all new classes/methods live in `RediStick-TimeSeries` (production) and
  `RediStick-TimeSeries-Tests` (tests) — both already registered in `BaselineOfRediStick` and
  `.smalltalk.ston`; **no baseline changes needed**.
- Follow the Tonel style guide from the `smalltalk-dev:smalltalk-developer` skill for every `.st`
  file edit.
- After every `.st` file edit: validate with
  `mcp__smalltalk-validator__validate_tonel_smalltalk_from_file`, then reimport with
  `mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries'` (and
  `'RediStick-TimeSeries-Tests'` when test files change), using absolute paths under
  `/home/mumez/git/RediStick/src`.
- Reuse existing helpers — do not reimplement:
  - `RsTsRange class >> normalizeTimestamp:` (`src/RediStick-TimeSeries/RsTsRange.class.st`) for
    cursor normalization (String sentinel pass-through, else `asRediStickUnixTimestampMillis`).
  - `RsRedisEndpoint >> tsParseRangeSamples:` and `tsParseValue:`
    (`src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`) for parsing the `(timestamp, value)`
    pair array reply — `TS.READ`'s reply shape is identical to `TS.RANGE`'s.
- No client-side timeout handling is needed for `BLOCK`: RediStick has no bespoke socket
  read-timeout logic for any blocking command (`BLPOP`/`XREAD ... BLOCK` already forward straight
  to `unifiedCommand:` and rely on the socket read blocking naturally until Redis replies — see
  `src/RediStick-Core/RsRedisEndpoint.class.st` and
  `src/RediStick-Stream/RsRedisEndpoint.extension.st`). `tsRead:cursor:using:` must follow the same
  pattern: just append the `BLOCK`/`MAX_COUNT` args and call `unifiedCommand:`.
- Test keys must use unique names per test (e.g. `'test:ts:read:basic'`), matching existing
  `RsTsTest` conventions. No explicit `dbIndex` selection needed inside test methods (handled by
  `RsRedisTestCase setUp`).
- The `BLOCK`-timeout integration test must use a short, fixed timeout (e.g. 300ms) with a
  `min_count` that can never be satisfied, so the wait duration is deterministic — do not write a
  test that races a forked writer against the block window (that pattern caused a prior flaky-CI
  incident with `testXGroupAutoClaim`; avoid repeating it here).
- Redis reference doc used for exact syntax: https://redis.io/docs/latest/commands/ts.read/
  (fetched and confirmed during planning — since 8.10.0, arity -3, syntax
  `TS.READ key timestamp [BLOCK milliseconds min_count] [MAX_COUNT max_count]`).

---

## Design Reference

### `TS.READ` full syntax
```
TS.READ key timestamp [BLOCK milliseconds min_count] [MAX_COUNT max_count]
```
- `timestamp` (the cursor) is inclusive-lower-bound: matches samples with
  `timestamp >= resolved_cursor`. It is either a non-negative integer Unix ms timestamp or one of
  the sentinels `-` (earliest), `+` (latest, inclusive), `$` (new-only: latest + 1). Sentinels are
  sent to the server as-is, never resolved client-side.
- `BLOCK milliseconds min_count` (optional): block until `min_count` qualifying samples exist or
  `milliseconds` elapse (0 = block indefinitely) or the key is removed. Omit to never block — the
  command then returns immediately with whatever is available (possibly an empty array).
- `MAX_COUNT max_count` (optional): caps the reply to the oldest `max_count` qualifying samples.
  Unbounded if omitted. `BLOCK` and `MAX_COUNT` are independent and may appear in either order;
  this implementation always emits `BLOCK` before `MAX_COUNT` for determinism.
- Reply: array of `(timestamp, value)` pairs ordered by increasing timestamp — identical shape to
  `TS.RANGE`'s reply. Empty array on no match, on timeout-with-nothing-available, or if the key was
  removed while blocked (all are successful replies, not errors).

### Class responsibilities

**`RsTsReadOptions`** (new, `Object` subclass, instance vars `blockMilliseconds`, `blockMinCount`,
`maxCount`):
- `block: milliseconds minCount: aMinCount` — sets both `BLOCK` fields together (Redis requires
  both or neither).
- `maxCount: anInteger` — sets `MAX_COUNT`.
- Accessors: `blockMilliseconds`, `blockMinCount`, `maxCount`.
- `asArray` emits, in order: `BLOCK ms minCount` (only if both `blockMilliseconds` and
  `blockMinCount` are non-nil), then `MAX_COUNT n` (if `maxCount` non-nil). Emits `#()` when
  nothing is set.

### `RsRedisEndpoint` methods to add

```
tsRead: key cursor: aTimestampOrSentinel
tsRead: key cursor: aTimestampOrSentinel using: optionsBlock
```
`aTimestampOrSentinel` is an `Integer`, `DateAndTime`, or one of the literal Strings `'-'`, `'+'`,
`'$'` (callers pass these sentinel strings directly — no dedicated cursor class/constants are
introduced by this plan since `RsTsRange` already owns `start`/`end`, and `'$'` has no existing
equivalent worth adding just for this). The cursor is normalized via
`RsTsRange normalizeTimestamp: aTimestampOrSentinel` (String pass-through, else
`asRediStickUnixTimestampMillis`) before being placed in the command args. `optionsBlock` (when
given) is evaluated as `optionsBlock value: anRsTsReadOptions`. The raw Redis reply is parsed via
the existing `tsParseRangeSamples:` helper, returning an `Array` of `Association`s
(`timestamp -> value`), matching `tsRange:...`'s existing return shape.

---

## Task 1: `RsTsReadOptions` value class

**Files:**
- Create: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsReadOptions.class.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsReadOptionsTest.class.st`

**Interfaces:**
- Produces: `RsTsReadOptions >> block:minCount:`, `maxCount:`, `blockMilliseconds`,
  `blockMinCount`, `maxCount`, `asArray`. Task 2 depends on these exact names.

This class needs no live Redis connection, so its test is a plain `TestCase` subclass (not
`RsRedisTestCase`) — it can be run without a Redis server.

- [x] **Step 1: Write the failing test file**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsReadOptionsTest.class.st`:

```
Class {
	#name : 'RsTsReadOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsReadOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsTsReadOptions new asArray equals: #()
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testBlock [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 5000 minCount: 2.
	self assertCollection: opts asArray equals: { 'BLOCK'. 5000. 2 }
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testMaxCount [
	| opts |
	opts := RsTsReadOptions new.
	opts maxCount: 10.
	self assertCollection: opts asArray equals: { 'MAX_COUNT'. 10 }
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testBlockAndMaxCountCombinedInRedisOrder [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 1000 minCount: 5; maxCount: 20.
	self assertCollection: opts asArray equals: { 'BLOCK'. 1000. 5. 'MAX_COUNT'. 20 }
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testBlockWithoutMinCountIsIgnored [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 1000 minCount: nil.
	self assertCollection: opts asArray equals: #()
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testAccessors [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 1500 minCount: 3; maxCount: 7.
	self assert: opts blockMilliseconds equals: 1500.
	self assert: opts blockMinCount equals: 3.
	self assert: opts maxCount equals: 7
]
```

- [x] **Step 2: Run to verify it fails**

Validate with `mcp__smalltalk-validator__validate_tonel_smalltalk_from_file`, then
`mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests'
path: '/home/mumez/git/RediStick/src'`. Confirm the import/test run fails because `RsTsReadOptions`
does not yet exist (class-not-found / doesNotUnderstand).

- [x] **Step 3: Write the implementation**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsReadOptions.class.st`:

```
Class {
	#name : 'RsTsReadOptions',
	#superclass : 'Object',
	#instVars : [
		'blockMilliseconds',
		'blockMinCount',
		'maxCount'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsReadOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	(self blockMilliseconds notNil and: [ self blockMinCount notNil ]) ifTrue: [
		opts addAll: { 'BLOCK'. self blockMilliseconds. self blockMinCount } ].
	self maxCount ifNotNil: [ :c | opts addAll: { 'MAX_COUNT'. c } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsReadOptions >> block: milliseconds minCount: aMinCount [
	blockMilliseconds := milliseconds.
	blockMinCount := aMinCount
]

{ #category : 'accessing' }
RsTsReadOptions >> blockMilliseconds [
	^ blockMilliseconds
]

{ #category : 'accessing' }
RsTsReadOptions >> blockMinCount [
	^ blockMinCount
]

{ #category : 'accessing' }
RsTsReadOptions >> maxCount [
	^ maxCount
]

{ #category : 'accessing' }
RsTsReadOptions >> maxCount: anInteger [
	maxCount := anInteger
]
```

- [x] **Step 4: Validate, reimport, run**

Validate with `mcp__smalltalk-validator__validate_tonel_smalltalk_from_file`, reimport
`RediStick-TimeSeries` then `RediStick-TimeSeries-Tests` (both with absolute path
`/home/mumez/git/RediStick/src`), then run `mcp__smalltalk-interop__run_class_test:
'RsTsReadOptionsTest'` and confirm all 6 tests pass.

- [x] **Step 5: Commit**

```
git add src/RediStick-TimeSeries/RsTsReadOptions.class.st src/RediStick-TimeSeries-Tests/RsTsReadOptionsTest.class.st
git commit -m "Add RsTsReadOptions for TS.READ BLOCK/MAX_COUNT options"
```

---

## Task 2: `RsRedisEndpoint >> tsRead:cursor:` / `tsRead:cursor:using:`

**Files:**
- Modify: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`
  (append new methods; do not touch any existing method in this file)
- Modify: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st` (append new
  test methods; do not touch any existing method in this file)

**Interfaces:**
- Consumes: `RsTsReadOptions` from Task 1 (already exists — do not recreate it), the existing
  `RsTsRange class >> normalizeTimestamp:` and `RsRedisEndpoint >> tsParseRangeSamples:` /
  `tsParseValue:` helpers (already exist — do not recreate or modify them).
- Produces: `RsRedisEndpoint >> tsRead:cursor:`, `tsRead:cursor:using:`.

This requires a live Redis connection with the RedisTimeSeries module (server 8.10+ for
`TS.READ`), the same way every other `RsTsTest` integration test in this package already does.

- [x] **Step 1: Write the failing test methods**

Append these methods to `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st`
(as new `{ #category : 'tests' }` chunks — do not reformat or touch any existing method):

```
{ #category : 'tests' }
RsTsTest >> testTsReadBasic [
	| key result |
	key := 'test:ts:read:basic'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRead: key cursor: 0.
	self assert: result size equals: 3.
	self assert: result first key equals: 1000.
	self assert: result third value equals: 40
]

{ #category : 'tests' }
RsTsTest >> testTsReadWithStartSentinel [
	| key result |
	key := 'test:ts:read:start'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.

	result := stick endpoint tsRead: key cursor: '-'.
	self assert: result size equals: 2
]

{ #category : 'tests' }
RsTsTest >> testTsReadWithLatestSentinel [
	| key result |
	key := 'test:ts:read:latest'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 2000 value: 40.

	result := stick endpoint tsRead: key cursor: '+'.
	self assert: result size equals: 1.
	self assert: result first key equals: 2000
]

{ #category : 'tests' }
RsTsTest >> testTsReadFromExplicitTimestamp [
	| key result |
	key := 'test:ts:read:explicit'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRead: key cursor: 1010.
	self assert: result size equals: 2.
	self assert: result first key equals: 1010
]

{ #category : 'tests' }
RsTsTest >> testTsReadEmptySeriesReturnsEmptyArray [
	| key result |
	key := 'test:ts:read:empty'.
	stick endpoint tsCreate: key.
	result := stick endpoint tsRead: key cursor: 0.
	self assertCollection: result equals: #()
]

{ #category : 'tests' }
RsTsTest >> testTsReadWithMaxCount [
	| key result |
	key := 'test:ts:read:maxcount'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRead: key cursor: 0 using: [ :opts | opts maxCount: 2 ].
	self assert: result size equals: 2.
	self assert: result first key equals: 1000.
	self assert: result second key equals: 1010
]

{ #category : 'tests' }
RsTsTest >> testTsReadWithBlockReturnsImmediatelyWhenMinCountAlreadyMet [
	| key result |
	key := 'test:ts:read:block:immediate'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.

	result := stick endpoint
		tsRead: key
		cursor: 0
		using: [ :opts | opts block: 5000 minCount: 2 ].
	self assert: result size equals: 2
]

{ #category : 'tests' }
RsTsTest >> testTsReadWithBlockReturnsPartialResultsAfterTimeout [
	| key result |
	key := 'test:ts:read:block:timeout'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.

	result := stick endpoint
		tsRead: key
		cursor: 0
		using: [ :opts | opts block: 300 minCount: 5 ].
	self assert: result size equals: 1
]
```

Note on `testTsReadWithBlockReturnsPartialResultsAfterTimeout`: `min_count: 5` can never be
satisfied by the single sample written, so the server blocks for the full 300ms before returning
the one available sample — this is a deterministic wait, not a race, so it should not be flaky.

- [x] **Step 2: Run to verify it fails**

Validate with `mcp__smalltalk-validator__validate_tonel_smalltalk_from_file`, reimport
`RediStick-TimeSeries-Tests`. Confirm the run fails because `tsRead:cursor:` /
`tsRead:cursor:using:` don't exist yet (doesNotUnderstand).

- [x] **Step 3: Write the implementation**

Append to `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st` (after
the existing `tsRevRange:...` methods, before the `tsIncrBy:...` methods — or simply at the end of
the file; exact position doesn't matter, just don't touch existing chunks):

```
{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRead: key cursor: aTimestampOrSentinel [
	^ self tsRead: key cursor: aTimestampOrSentinel using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRead: key cursor: aTimestampOrSentinel using: optionsBlock [
	| args options |
	args := {
		        'TS.READ'.
		        key.
		        (RsTsRange normalizeTimestamp: aTimestampOrSentinel) } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsTsReadOptions new.
		optionsBlock value: options.
		args addAll: options asArray ].
	^ self tsParseRangeSamples: (self unifiedCommand: args asArray)
]
```

- [x] **Step 4: Validate, reimport, run**

Validate with `mcp__smalltalk-validator__validate_tonel_smalltalk_from_file`, reimport
`RediStick-TimeSeries` then `RediStick-TimeSeries-Tests`, then run
`mcp__smalltalk-interop__run_class_test: 'RsTsTest'` against the live Redis/RedisTimeSeries
instance (server must support `TS.READ`, i.e. RedisTimeSeries module built against Redis 8.10+ —
if the live instance is older and `TS.READ` returns an unknown-command error, report that
explicitly rather than claiming success). Confirm all `RsTsTest` tests pass, including the 8 new
`testTsRead*` methods.

- [x] **Step 5: Commit**

```
git add src/RediStick-TimeSeries/RsRedisEndpoint.extension.st src/RediStick-TimeSeries-Tests/RsTsTest.class.st
git commit -m "Add RsRedisEndpoint>>tsRead:cursor: for TS.READ support"
```

---

## Task 3: Full-package regression check + lint

- [x] **Step 1: Run the full test package**

Run `mcp__smalltalk-interop__run_package_test: 'RediStick-TimeSeries-Tests'` and confirm 0
failures / 0 errors across all classes in the package (including the pre-existing `RsTsTest`,
`RsTsMAddTest`, `RsTsRangeTest`, `RsTsRangeOptionsTest`, `RsTsAggregationTest`,
`RsTsAggregationOptionsTest`, `RsTsFilterTest`, `RsTsFilterBuilderTest`, `RsTsMGetOptionsTest`,
`RsTsValueTest`, `RsTsMGetTest`, `RsTsQueryIndexTest`, `RsTsCreateRuleTest`/equivalents, plus the
two new classes `RsTsReadOptionsTest` and the new `testTsRead*` methods added to `RsTsTest` in
Tasks 1-2). If the live Redis instance doesn't support `TS.READ` (pre-8.10 RedisTimeSeries), report
that explicitly — don't mark this task done on a false pass.

- [x] **Step 2: Lint**

Run `mcp__smalltalk-validator__lint_tonel_smalltalk_from_file` on every file created or modified in
Tasks 1-2: `RsTsReadOptions.class.st`, `RsTsReadOptionsTest.class.st`,
`RsRedisEndpoint.extension.st`, `RsTsTest.class.st`. Consult the `smalltalk-dev:smalltalk-developer`
skill's style guide and the `st-lint` skill for this project's Tonel conventions, and fix any
findings, re-running the affected class test after each fix.

- [x] **Step 3: Fix lint findings in TS.READ implementation (only if needed)**

If Step 2 required any fixes, commit them:

```
git add <fixed files>
git commit -m "Fix lint findings in TS.READ implementation"
```

If nothing needed fixing, skip this commit (no empty commits).

- [x] **Step 4: Update CLAUDE.local.md TODO**

Mark the `1788748958227-ts-read-コマンド対応` line item as done in
`/home/mumez/git/RediStick/CLAUDE.local.md` if it is tracked there (check the "TODO" sections at
the top of the file first — this file is not checked into git, so this step only matters for local
tracking continuity, not for the commit history).

---

## Self-Review Notes

- **Spec coverage:** `timestamp` cursor (literal + `-`/`+`/`$` sentinels), `BLOCK milliseconds
  min_count`, `MAX_COUNT max_count`, empty-array replies (no match / timeout / key removed while
  blocked) are all covered by Task 2's test list.
- **No placeholders:** every code block above is complete, runnable Tonel — no `...` elisions.
- **Name consistency:** `tsRead:cursor:` / `tsRead:cursor:using:` follow the existing `tsGet:` /
  `tsGet:latest:` and `tsRange:rangeBy:using:` naming style already in this file; `RsTsReadOptions`
  follows the existing `RsTsRangeOptions`/`RsTsMGetOptions` naming style.
- **Reuse over duplication:** cursor normalization and reply parsing both reuse existing helpers
  (`RsTsRange normalizeTimestamp:`, `tsParseRangeSamples:`) rather than introducing new ones — no
  new cursor class was introduced since a bare String/Integer/DateAndTime argument plus the
  existing normalizer fully covers the spec.
