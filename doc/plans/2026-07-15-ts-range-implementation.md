# TS.RANGE / TS.REVRANGE Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Redis `TS.RANGE` and `TS.REVRANGE` commands in the existing `RediStick-TimeSeries` package, following the fluent `rangeBy:`/`aggregationBy:`/`using:` design recorded in `CLAUDE.local.md`.

**Architecture:** Add four small value/option classes (`RsTsRange`, `RsTsRangeOptions`, `RsTsAggregation`, `RsTsAggregationOptions`) plus new `RsRedisEndpoint` extension methods `tsRange:rangeBy:using:`, `tsRange:rangeBy:aggregationBy:using:`, `tsRevRange:rangeBy:using:`, `tsRevRange:rangeBy:aggregationBy:using:`. Pure value-object logic (range normalization, option-array building) is unit-tested without Redis; the endpoint methods are integration-tested against a live Redis in `RsTsTest` (subclass of `RsRedisTestCase`), matching the existing `TS.ADD`/`TS.CREATE` tests already in that file.

**Tech Stack:** Pharo Smalltalk (Tonel `.st` files), SUnit, smalltalk-interop / smalltalk-validator MCP tools, `RsRedisTestCase` test harness against a live Redis Stack instance.

## Global Constraints

- Package: all new classes/methods live in `RediStick-TimeSeries` (production) and `RediStick-TimeSeries-Tests` (tests) — both already registered in `BaselineOfRediStick` and `.smalltalk.ston`; **no baseline changes needed**.
- Follow the Tonel style guide from the `smalltalk-dev:smalltalk-developer` skill for every `.st` file edit.
- After every `.st` file edit: validate with `mcp__smalltalk-validator__validate_tonel_smalltalk_from_file`, then reimport with `mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries'` (and `'RediStick-TimeSeries-Tests'` when test files change), using absolute paths under `/home/mumez/git/RediStick/src`.
- Required arguments stay as ordinary keyword arguments; the many-optional-parameter commands use the `using: optionsBlock` pattern already established by `RsJsonArrOptions`/`RsTsAddOptions` (see `src/RediStick-Json/RsJsonArrOptions.class.st` and `src/RediStick-TimeSeries/RsTsAddOptions.class.st` for the idiom: plain `Object` subclass, one instance variable per option, `asArray` builds the Redis argument fragment).
- Timestamp normalization reuses the existing extensions: `Integer >> asRediStickUnixTimestampMillis` (returns `self`) and `DateAndTime >> asRediStickUnixTimestampMillis` (converts to epoch millis) — both already implemented in `src/RediStick-TimeSeries/Integer.extension.st` and `src/RediStick-TimeSeries/DateAndTime.extension.st`. Do not re-implement these.
- `'-'` and `'+'` (the Redis "earliest"/"latest" sentinels) are passed through unchanged — never sent `asRediStickUnixTimestampMillis` (Strings don't implement it).
- Name resolution for the ambiguous parts of the CLAUDE.local.md draft (confirmed with user):
  - `RsTsRange` exposes **`start`**/**`end`** (not `begin`).
  - `RsTsRange` exposes short **`from:`** / **`to:`** single-arg convenience constructors (not `fromStartTo:`/`toEndFrom:`).
- Test keys must use unique names per test (e.g. `'test:ts:range:basic'`) to avoid cross-test collisions, matching existing `RsTsTest` conventions. No explicit `dbIndex` selection needed inside test methods (handled by `RsRedisTestCase setUp`, as in existing tests).
- Redis reference docs used for exact syntax: https://redis.io/docs/latest/commands/ts.range/ and https://redis.io/docs/latest/commands/ts.revrange/ (fetched and confirmed identical option syntax between the two commands; only direction of results differs).

---

## Design Reference (from CLAUDE.local.md + this session's research)

### `TS.RANGE` / `TS.REVRANGE` full syntax
```
TS.RANGE key fromTimestamp toTimestamp [LATEST]
  [FILTER_BY_TS ts [ts ...]] [FILTER_BY_VALUE min max]
  [COUNT count] [[ALIGN value] AGGREGATION aggregators bucketDuration [BUCKETTIMESTAMP bt] [EMPTY]]
```
`TS.REVRANGE` is syntactically identical (same option grammar), only key/direction differs — same argument-building code will be reused for both, only the command name token changes.

Aggregators (Redis token -> Smalltalk unary selector on `RsTsAggregation`):
`avg`, `sum`, `min`, `max`, `range`, `count`, `countNaN`, `countAll`, `first`, `last`, `std.p`→`stdP`, `std.s`→`stdS`, `var.p`→`varP`, `var.s`→`varS`, `twa`.

### Class responsibilities

**`RsTsRange`** (value object, instance vars `from`, `to`):
- Class-side: `from: aFrom to: aTo`, `from: aFrom` (to defaults to `self end`), `to: aTo` (from defaults to `self start`), `start` (→ `'-'`), `end` (→ `'+'`), `all` (→ `self from: self start to: self end`).
- Class-side private: `normalizeTimestamp: aValue` — if `aValue` is a `String` (already `'-'`/`'+'`), return as-is; otherwise send `aValue asRediStickUnixTimestampMillis`.
- Instance-side: `from`, `to` accessors; `asArray` → `{ from. to }`.

**`RsTsRangeOptions`** (outer options: `LATEST`, `FILTER_BY_TS`, `FILTER_BY_VALUE`, `COUNT`):
- `latest` (unary — sets flag true), `filterByTs:` (array of timestamps, each normalized), `filterByValueMin:max:`, `count:`.
- `asArray` emits, in Redis order: `LATEST` (if set), `FILTER_BY_TS ts...` (if set), `FILTER_BY_VALUE min max` (if both set), `COUNT n` (if set).

**`RsTsAggregation`** (aggregator selection + bucket duration):
- One unary method per aggregator token (adds to an internal ordered list of tokens), plus `bucketDuration:`.
- `asArray` → `{ 'AGGREGATION'. <comma-joined tokens>. bucketDuration }`.

**`RsTsAggregationOptions`** (`ALIGN`, `BUCKETTIMESTAMP`, `EMPTY` — these wrap the aggregation block, per Redis grammar `[ALIGN v] AGGREGATION ... [BUCKETTIMESTAMP bt] [EMPTY]`):
- `align:` (normalizes via same rule as `RsTsRange normalizeTimestamp:` — String passthrough or `asRediStickUnixTimestampMillis`), `bucketTimestamp:` (raw token string: `'-'`/`'start'`/`'+'`/`'end'`/`'~'`/`'mid'`), `empty` (unary flag).
- `alignArray` → `{ 'ALIGN'. align }` or `{}` if unset.
- `tailArray` → `BUCKETTIMESTAMP bt` (if set) and/or `EMPTY` (if set), in that order.

### `RsRedisEndpoint` methods to add

```
tsRange: key rangeBy: rangeBlock using: optionsBlock
tsRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock
tsRevRange: key rangeBy: rangeBlock using: optionsBlock
tsRevRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock
```
`rangeBlock` is evaluated as `rangeBlock value: RsTsRange` (the class itself is passed in, so the block can call `r from: 123 to: 456`, `r all`, `r start`, `r end`, or return a raw Association like `123 -> 456` / `r start -> 456` / `123 -> r end`). The result is normalized to an `RsTsRange` instance by a private helper (`tsRangeFrom:`) that accepts either an `RsTsRange` (used as-is) or an `Association` (built into `RsTsRange from: key to: value`).

`aggregationBlock` is evaluated as `aggregationBlock value: anRsTsAggregation value: anRsTsAggregationOptions` (two args).

Result rows come back from Redis as `[[ts, val], [ts, val], ...]` (or `[ts, val1, val2, ...]` per row when multiple aggregators are requested). A shared private helper `tsParseRangeSamples:` converts this into an `Array` of `Association`s: `ts -> value` for the 2-element case, `ts -> (Array of values)` for the multi-aggregator case — using the existing `tsParseValue:` helper for numeric parsing. `nil`/empty Redis replies become `#()`.

---

## Task 1: `RsTsRange` value class

**Files:**
- Create: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsRange.class.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsRangeTest.class.st`

**Interfaces:**
- Produces: `RsTsRange class >> from:to:`, `from:`, `to:`, `start`, `end`, `all`; `RsTsRange >> from`, `to`, `asArray`. Later tasks depend on these exact names.

This class needs no live Redis connection, so its test is a plain `TestCase` subclass (not `RsRedisTestCase`) — it can be run without a Redis server.

- [ ] **Step 1: Write the failing test file**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsRangeTest.class.st`:

```
Class {
	#name : 'RsTsRangeTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsRangeTest >> testAllUsesStartAndEnd [
	| range |
	range := RsTsRange all.
	self assert: range from equals: '-'.
	self assert: range to equals: '+'
]

{ #category : 'tests' }
RsTsRangeTest >> testAsArray [
	| range |
	range := RsTsRange from: 1000 to: 2000.
	self assertCollection: range asArray equals: { 1000. 2000 }
]

{ #category : 'tests' }
RsTsRangeTest >> testFromToWithIntegers [
	| range |
	range := RsTsRange from: 1000 to: 2000.
	self assert: range from equals: 1000.
	self assert: range to equals: 2000
]

{ #category : 'tests' }
RsTsRangeTest >> testFromOnlyDefaultsToEnd [
	| range |
	range := RsTsRange from: 1000.
	self assert: range from equals: 1000.
	self assert: range to equals: '+'
]

{ #category : 'tests' }
RsTsRangeTest >> testToOnlyDefaultsFromStart [
	| range |
	range := RsTsRange to: 2000.
	self assert: range from equals: '-'.
	self assert: range to equals: 2000
]

{ #category : 'tests' }
RsTsRangeTest >> testStartAndEndSentinels [
	self assert: RsTsRange start equals: '-'.
	self assert: RsTsRange end equals: '+'
]

{ #category : 'tests' }
RsTsRangeTest >> testFromToWithDateAndTime [
	| now range |
	now := DateAndTime now.
	range := RsTsRange from: now to: now.
	self assert: range from equals: now asRediStickUnixTimestampMillis.
	self assert: range to equals: now asRediStickUnixTimestampMillis
]
```

- [ ] **Step 2: Validate and import the (currently failing) test package**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsRangeTest.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsRangeTest'
```
Expected: import or run fails because `RsTsRange` does not exist yet (`MessageNotUnderstood`/`ClassNotDefined` style errors reported by the test runner).

- [ ] **Step 3: Write the `RsTsRange` implementation**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsRange.class.st`:

```
Class {
	#name : 'RsTsRange',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsRange class >> all [
	^ self from: self start to: self end
]

{ #category : 'instance creation' }
RsTsRange class >> end [
	^ '+'
]

{ #category : 'instance creation' }
RsTsRange class >> from: aFrom [
	^ self from: aFrom to: self end
]

{ #category : 'instance creation' }
RsTsRange class >> from: aFrom to: aTo [
	^ self new
		setFrom: (self normalizeTimestamp: aFrom)
		to: (self normalizeTimestamp: aTo)
]

{ #category : 'private' }
RsTsRange class >> normalizeTimestamp: aValue [
	aValue isString ifTrue: [ ^ aValue ].
	^ aValue asRediStickUnixTimestampMillis
]

{ #category : 'instance creation' }
RsTsRange class >> start [
	^ '-'
]

{ #category : 'instance creation' }
RsTsRange class >> to: aTo [
	^ self from: self start to: aTo
]

{ #category : 'converting' }
RsTsRange >> asArray [
	^ { from. to }
]

{ #category : 'accessing' }
RsTsRange >> from [
	^ from
]

{ #category : 'accessing' }
RsTsRange >> to [
	^ to
]

{ #category : 'private' }
RsTsRange >> setFrom: aFrom to: aTo [
	from := aFrom.
	to := aTo
]
```

- [ ] **Step 4: Validate, import, and run the test**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsRange.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsRangeTest'
```
Expected: PASS, 7/7 tests green.

- [ ] **Step 5: Commit**

```bash
git add src/RediStick-TimeSeries/RsTsRange.class.st src/RediStick-TimeSeries-Tests/RsTsRangeTest.class.st
git commit -m "Add RsTsRange value class for TS.RANGE from/to construction"
```

---

## Task 2: `RsTsRangeOptions` class

**Files:**
- Create: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsRangeOptions.class.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsRangeOptionsTest.class.st`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: `RsTsRangeOptions >> latest`, `filterByTs:`, `filterByValueMin:max:`, `count:`, `asArray`. Task 4/5 depend on these exact names.

- [ ] **Step 1: Write the failing test file**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsRangeOptionsTest.class.st`:

```
Class {
	#name : 'RsTsRangeOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsRangeOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsTsRangeOptions new asArray equals: #()
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testLatestFlag [
	| opts |
	opts := RsTsRangeOptions new.
	opts latest.
	self assertCollection: opts asArray equals: { 'LATEST' }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testFilterByTs [
	| opts |
	opts := RsTsRangeOptions new.
	opts filterByTs: { 1000. 2000 }.
	self assertCollection: opts asArray equals: { 'FILTER_BY_TS'. 1000. 2000 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testFilterByValue [
	| opts |
	opts := RsTsRangeOptions new.
	opts filterByValueMin: -100 max: 100.
	self assertCollection: opts asArray equals: { 'FILTER_BY_VALUE'. -100. 100 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testCount [
	| opts |
	opts := RsTsRangeOptions new.
	opts count: 10.
	self assertCollection: opts asArray equals: { 'COUNT'. 10 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testAllOptionsCombinedInRedisOrder [
	| opts |
	opts := RsTsRangeOptions new.
	opts
		latest;
		filterByTs: { 1000 };
		filterByValueMin: -100 max: 100;
		count: 10.
	self assertCollection: opts asArray
		equals: { 'LATEST'. 'FILTER_BY_TS'. 1000. 'FILTER_BY_VALUE'. -100. 100. 'COUNT'. 10 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testFilterByTsNormalizesDateAndTime [
	| opts now |
	now := DateAndTime now.
	opts := RsTsRangeOptions new.
	opts filterByTs: { now }.
	self assertCollection: opts asArray equals: { 'FILTER_BY_TS'. now asRediStickUnixTimestampMillis }
]
```

- [ ] **Step 2: Run to verify it fails**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsRangeOptionsTest.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsRangeOptionsTest'
```
Expected: FAIL (`RsTsRangeOptions` not defined).

- [ ] **Step 3: Write the `RsTsRangeOptions` implementation**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsRangeOptions.class.st`:

```
Class {
	#name : 'RsTsRangeOptions',
	#superclass : 'Object',
	#instVars : [
		'latest',
		'filterByTs',
		'filterByValueMin',
		'filterByValueMax',
		'count'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsRangeOptions >> initialize [
	super initialize.
	latest := false
]

{ #category : 'converting' }
RsTsRangeOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	latest ifTrue: [ opts add: 'LATEST' ].
	filterByTs ifNotNil: [ :ts |
		opts add: 'FILTER_BY_TS'.
		opts addAll: ts ].
	(filterByValueMin notNil and: [ filterByValueMax notNil ]) ifTrue: [
		opts addAll: { 'FILTER_BY_VALUE'. filterByValueMin. filterByValueMax } ].
	count ifNotNil: [ :c | opts addAll: { 'COUNT'. c } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsRangeOptions >> count: anInteger [
	count := anInteger
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByTs: aCollectionOfTimestamps [
	filterByTs := aCollectionOfTimestamps collect: [ :ts |
		ts isString ifTrue: [ ts ] ifFalse: [ ts asRediStickUnixTimestampMillis ] ]
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByValueMin: aMin max: aMax [
	filterByValueMin := aMin.
	filterByValueMax := aMax
]

{ #category : 'accessing' }
RsTsRangeOptions >> latest [
	latest := true
]
```

- [ ] **Step 4: Validate, import, and run**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsRangeOptions.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsRangeOptionsTest'
```
Expected: PASS, 7/7 tests green.

- [ ] **Step 5: Commit**

```bash
git add src/RediStick-TimeSeries/RsTsRangeOptions.class.st src/RediStick-TimeSeries-Tests/RsTsRangeOptionsTest.class.st
git commit -m "Add RsTsRangeOptions for TS.RANGE LATEST/FILTER_BY_TS/FILTER_BY_VALUE/COUNT"
```

---

## Task 3: `RsTsAggregation` and `RsTsAggregationOptions` classes

**Files:**
- Create: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsAggregation.class.st`
- Create: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsAggregationOptions.class.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsAggregationTest.class.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsAggregationOptionsTest.class.st`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `RsTsAggregation >> avg`, `sum`, `min`, `max`, `range`, `count`, `countNaN`, `countAll`, `first`, `last`, `stdP`, `stdS`, `varP`, `varS`, `twa`, `bucketDuration:`, `asArray`. `RsTsAggregationOptions >> align:`, `bucketTimestamp:`, `empty`, `alignArray`, `tailArray`. Task 6/7 depend on these exact names.

- [ ] **Step 1: Write the failing test files**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsAggregationTest.class.st`:

```
Class {
	#name : 'RsTsAggregationTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsAggregationTest >> testSingleAggregator [
	| agg |
	agg := RsTsAggregation new.
	agg min.
	agg bucketDuration: 1000.
	self assertCollection: agg asArray equals: { 'AGGREGATION'. 'min'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationTest >> testMultipleAggregatorsJoinedByComma [
	| agg |
	agg := RsTsAggregation new.
	agg min; avg; max.
	agg bucketDuration: 20.
	self assertCollection: agg asArray equals: { 'AGGREGATION'. 'min,avg,max'. 20 }
]

{ #category : 'tests' }
RsTsAggregationTest >> testAllAggregatorTokens [
	#( #avg 'avg' #sum 'sum' #min 'min' #max 'max' #range 'range' #count 'count'
	   #countNaN 'countNaN' #countAll 'countAll' #first 'first' #last 'last'
	   #stdP 'std.p' #stdS 'std.s' #varP 'var.p' #varS 'var.s' #twa 'twa' )
		pairsDo: [ :selector :token |
			| agg |
			agg := RsTsAggregation new.
			agg perform: selector.
			agg bucketDuration: 1.
			self assertCollection: agg asArray equals: { 'AGGREGATION'. token. 1 } ]
]
```

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsAggregationOptionsTest.class.st`:

```
Class {
	#name : 'RsTsAggregationOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testEmptyOptionsProduceEmptyArrays [
	| opts |
	opts := RsTsAggregationOptions new.
	self assertCollection: opts alignArray equals: #().
	self assertCollection: opts tailArray equals: #()
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignWithInteger [
	| opts |
	opts := RsTsAggregationOptions new.
	opts align: 10.
	self assertCollection: opts alignArray equals: { 'ALIGN'. 10 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignWithSentinelString [
	| opts |
	opts := RsTsAggregationOptions new.
	opts align: '-'.
	self assertCollection: opts alignArray equals: { 'ALIGN'. '-' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestamp [
	| opts |
	opts := RsTsAggregationOptions new.
	opts bucketTimestamp: '+'.
	self assertCollection: opts tailArray equals: { 'BUCKETTIMESTAMP'. '+' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testEmptyFlag [
	| opts |
	opts := RsTsAggregationOptions new.
	opts empty.
	self assertCollection: opts tailArray equals: { 'EMPTY' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestampAndEmptyCombinedInOrder [
	| opts |
	opts := RsTsAggregationOptions new.
	opts bucketTimestamp: '~'; empty.
	self assertCollection: opts tailArray equals: { 'BUCKETTIMESTAMP'. '~'. 'EMPTY' }
]
```

- [ ] **Step 2: Run to verify both fail**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsAggregationTest.class.st'
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsAggregationOptionsTest.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsAggregationTest'
mcp__smalltalk-interop__run_class_test: 'RsTsAggregationOptionsTest'
```
Expected: FAIL (`RsTsAggregation`/`RsTsAggregationOptions` not defined).

- [ ] **Step 3: Write the `RsTsAggregation` implementation**

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsAggregation.class.st`:

```
Class {
	#name : 'RsTsAggregation',
	#superclass : 'Object',
	#instVars : [
		'aggregators',
		'bucketDuration'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsAggregation >> initialize [
	super initialize.
	aggregators := OrderedCollection new
]

{ #category : 'aggregators' }
RsTsAggregation >> avg [
	aggregators add: 'avg'
]

{ #category : 'accessing' }
RsTsAggregation >> bucketDuration: anInteger [
	bucketDuration := anInteger
]

{ #category : 'aggregators' }
RsTsAggregation >> count [
	aggregators add: 'count'
]

{ #category : 'aggregators' }
RsTsAggregation >> countAll [
	aggregators add: 'countAll'
]

{ #category : 'aggregators' }
RsTsAggregation >> countNaN [
	aggregators add: 'countNaN'
]

{ #category : 'aggregators' }
RsTsAggregation >> first [
	aggregators add: 'first'
]

{ #category : 'aggregators' }
RsTsAggregation >> last [
	aggregators add: 'last'
]

{ #category : 'aggregators' }
RsTsAggregation >> max [
	aggregators add: 'max'
]

{ #category : 'aggregators' }
RsTsAggregation >> min [
	aggregators add: 'min'
]

{ #category : 'aggregators' }
RsTsAggregation >> range [
	aggregators add: 'range'
]

{ #category : 'aggregators' }
RsTsAggregation >> stdP [
	aggregators add: 'std.p'
]

{ #category : 'aggregators' }
RsTsAggregation >> stdS [
	aggregators add: 'std.s'
]

{ #category : 'aggregators' }
RsTsAggregation >> sum [
	aggregators add: 'sum'
]

{ #category : 'aggregators' }
RsTsAggregation >> twa [
	aggregators add: 'twa'
]

{ #category : 'aggregators' }
RsTsAggregation >> varP [
	aggregators add: 'var.p'
]

{ #category : 'aggregators' }
RsTsAggregation >> varS [
	aggregators add: 'var.s'
]

{ #category : 'converting' }
RsTsAggregation >> asArray [
	^ { 'AGGREGATION'. (aggregators fold: [ :a :b | a , ',' , b ]). bucketDuration }
]
```

Create `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsAggregationOptions.class.st`:

```
Class {
	#name : 'RsTsAggregationOptions',
	#superclass : 'Object',
	#instVars : [
		'align',
		'bucketTimestamp',
		'empty'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsAggregationOptions >> initialize [
	super initialize.
	empty := false
]

{ #category : 'converting' }
RsTsAggregationOptions >> alignArray [
	^ align ifNil: [ #() ] ifNotNil: [ { 'ALIGN'. align } ]
]

{ #category : 'accessing' }
RsTsAggregationOptions >> align: aValue [
	align := aValue isString ifTrue: [ aValue ] ifFalse: [ aValue asRediStickUnixTimestampMillis ]
]

{ #category : 'accessing' }
RsTsAggregationOptions >> bucketTimestamp: aToken [
	bucketTimestamp := aToken
]

{ #category : 'accessing' }
RsTsAggregationOptions >> empty [
	empty := true
]

{ #category : 'converting' }
RsTsAggregationOptions >> tailArray [
	| opts |
	opts := OrderedCollection new.
	bucketTimestamp ifNotNil: [ :bt | opts addAll: { 'BUCKETTIMESTAMP'. bt } ].
	empty ifTrue: [ opts add: 'EMPTY' ].
	^ opts asArray
]
```

- [ ] **Step 4: Validate, import, and run both tests**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsAggregation.class.st'
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsTsAggregationOptions.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsAggregationTest'
mcp__smalltalk-interop__run_class_test: 'RsTsAggregationOptionsTest'
```
Expected: PASS on both (3/3 and 6/6 respectively).

- [ ] **Step 5: Commit**

```bash
git add src/RediStick-TimeSeries/RsTsAggregation.class.st src/RediStick-TimeSeries/RsTsAggregationOptions.class.st \
  src/RediStick-TimeSeries-Tests/RsTsAggregationTest.class.st src/RediStick-TimeSeries-Tests/RsTsAggregationOptionsTest.class.st
git commit -m "Add RsTsAggregation and RsTsAggregationOptions for TS.RANGE AGGREGATION"
```

---

## Task 4: `RsRedisEndpoint >> tsRange:rangeBy:using:` (no aggregation)

**Files:**
- Modify: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st`

**Interfaces:**
- Consumes: `RsTsRange` (Task 1), `RsTsRangeOptions` (Task 2), and the existing `tsParseValue:` (already in `RsRedisEndpoint.extension.st`), `flattenedKeysAndValuesFrom:` (existing, unrelated here), `unifiedCommand:` (existing).
- Produces: `RsRedisEndpoint >> tsRange:rangeBy:using:`, plus private helpers `tsRangeFrom:`, `tsRangeArgsFor:key:range:options:aggregation:aggOptions:`, `tsParseRangeSamples:`. Task 5, 6, 7 depend on these exact private helper names/signatures.

This task requires a live Redis connection for the integration test — use `mcp__smalltalk-interop__run_class_test` which runs against the configured test Redis (per `RsRedisTestCase`), same as all existing `RsTsTest` tests.

- [ ] **Step 1: Write the failing integration tests**

Add to `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st` (new methods, in the `tests` category):

```
{ #category : 'tests' }
RsTsTest >> testTsRangeBasic [
	| key result |
	key := 'test:ts:range:basic'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRange: key rangeBy: [ :r | r all ] using: nil.
	self assert: result size equals: 3.
	self assert: (result at: 1) key equals: 1000.
	self assert: (result at: 1) value equals: 30.
	self assert: (result at: 3) value equals: 40
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithExplicitFromTo [
	| key result |
	key := 'test:ts:range:explicit'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r from: 1000 to: 1010 ]
		using: nil.
	self assert: result size equals: 2.
	self assert: (result at: 2) key equals: 1010
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithAssociationRangeBlock [
	| key result |
	key := 'test:ts:range:association'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.

	result := stick endpoint tsRange: key rangeBy: [ :r | 1000 -> r end ] using: nil.
	self assert: result size equals: 2
]

{ #category : 'tests' }
RsTsTest >> testTsRangeEmptySeriesReturnsEmptyArray [
	| key result |
	key := 'test:ts:range:empty'.
	stick endpoint tsCreate: key.
	result := stick endpoint tsRange: key rangeBy: [ :r | r all ] using: nil.
	self assertCollection: result equals: #()
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithFilterByValueAndCount [
	| key result |
	key := 'test:ts:range:filters'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 9999.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		using: [ :opts | opts filterByValueMin: -100 max: 100 ].
	self assert: result size equals: 2.
	self assert: (result at: 1) value equals: 30.
	self assert: (result at: 2) value equals: 40
]
```

- [ ] **Step 2: Run to verify it fails**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsTest'
```
Expected: FAIL — the 5 new tests error with "does not understand `tsRange:rangeBy:using:`"; the existing tests still pass.

- [ ] **Step 3: Add the `tsRange:rangeBy:using:` implementation**

Add to `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st` (new methods appended to the extension body):

```
{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock using: optionsBlock [
	| range options args |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	args := self
		tsRangeArgsFor: 'TS.RANGE'
		key: key
		range: range
		options: options
		aggregation: nil
		aggOptions: nil.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsRangeFrom: rangeBlockResult [
	(rangeBlockResult isKindOf: RsTsRange) ifTrue: [ ^ rangeBlockResult ].
	^ RsTsRange from: rangeBlockResult key to: rangeBlockResult value
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsRangeArgsFor: cmdName key: key range: aTsRange options: options aggregation: aggregation aggOptions: aggOptions [
	| args |
	args := OrderedCollection new.
	args add: cmdName; add: key.
	args addAll: aTsRange asArray.
	options ifNotNil: [ args addAll: options asArray ].
	aggOptions ifNotNil: [ args addAll: aggOptions alignArray ].
	aggregation ifNotNil: [ args addAll: aggregation asArray ].
	aggOptions ifNotNil: [ args addAll: aggOptions tailArray ].
	^ args asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseRangeSamples: rawResult [
	rawResult ifNil: [ ^ #() ].
	^ (rawResult collect: [ :row |
		row size = 2
			ifTrue: [ row first -> (self tsParseValue: row second) ]
			ifFalse: [ row first -> ((row allButFirst) collect: [ :v | self tsParseValue: v ]) ] ])
		asArray
]
```

- [ ] **Step 4: Validate, import, and run the tests**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsTest'
```
Expected: PASS — all `RsTsTest` tests green, including the 5 new ones.

- [ ] **Step 5: Commit**

```bash
git add src/RediStick-TimeSeries/RsRedisEndpoint.extension.st src/RediStick-TimeSeries-Tests/RsTsTest.class.st
git commit -m "Add TS.RANGE support via tsRange:rangeBy:using:"
```

---

## Task 5: `RsRedisEndpoint >> tsRange:rangeBy:aggregationBy:using:`

**Files:**
- Modify: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st`

**Interfaces:**
- Consumes: `RsTsAggregation`, `RsTsAggregationOptions` (Task 3), `tsRangeFrom:`, `tsRangeArgsFor:key:range:options:aggregation:aggOptions:`, `tsParseRangeSamples:` (Task 4).
- Produces: `RsRedisEndpoint >> tsRange:rangeBy:aggregationBy:using:`.

- [ ] **Step 1: Write the failing integration tests**

Add to `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st`:

```
{ #category : 'tests' }
RsTsTest >> testTsRangeWithSingleAggregator [
	| key result |
	key := 'test:ts:range:agg:single'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 1010 value: 110.
	stick endpoint tsAdd: key timestamp: 1020 value: 120.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts | aggs min; bucketDuration: 20 ]
		using: nil.
	self assert: result size equals: 2.
	self assert: (result at: 1) value equals: 100.
	self assert: (result at: 2) value equals: 120
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithMultipleAggregators [
	| key result |
	key := 'test:ts:range:agg:multi'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts | aggs min; avg; max; bucketDuration: 1000 ]
		using: nil.
	self assert: result size equals: 1.
	self assert: (result at: 1) value size equals: 3.
	self assert: ((result at: 1) value at: 1) equals: 30.
	self assert: ((result at: 1) value at: 3) equals: 40
]

{ #category : 'tests' }
RsTsTest >> testTsRangeAggregationWithAlign [
	| key result |
	key := 'test:ts:range:agg:align'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 1010 value: 110.
	stick endpoint tsAdd: key timestamp: 1020 value: 120.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts |
			aggOpts align: 10.
			aggs min; bucketDuration: 20 ]
		using: nil.
	self assert: (result at: 1) key equals: 990
]

{ #category : 'tests' }
RsTsTest >> testTsRangeAggregationWithBucketTimestampAndEmpty [
	| key result |
	key := 'test:ts:range:agg:empty'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 3000 value: 300.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts |
			aggOpts bucketTimestamp: '+'; empty.
			aggs sum; bucketDuration: 1000 ]
		using: nil.
	self assert: result size equals: 3.
	self assert: (result at: 2) value equals: 0
]
```

- [ ] **Step 2: Run to verify it fails**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsTest'
```
Expected: FAIL — the 4 new tests error with "does not understand `tsRange:rangeBy:aggregationBy:using:`".

- [ ] **Step 3: Add the `tsRange:rangeBy:aggregationBy:using:` implementation**

Add to `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`:

```
{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
	| range options args aggregation aggOptions |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	aggregation := RsTsAggregation new.
	aggOptions := RsTsAggregationOptions new.
	aggregationBlock value: aggregation value: aggOptions.
	args := self
		tsRangeArgsFor: 'TS.RANGE'
		key: key
		range: range
		options: options
		aggregation: aggregation
		aggOptions: aggOptions.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]
```

- [ ] **Step 4: Validate, import, and run the tests**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsTest'
```
Expected: PASS — all `RsTsTest` tests green, including the 4 new ones.

**Note:** if `testTsRangeAggregationWithAlign` or `testTsRangeAggregationWithBucketTimestampAndEmpty` fail on the exact bucket boundary values, use `mcp__smalltalk-interop__eval` to run the equivalent raw `TS.RANGE` command directly against Redis (see `CLAUDE.md`'s "Interactive Testing and Debugging" section) and adjust the expected value in the test to match observed Redis behavior — the arithmetic in the task description mirrors the official `ts.range` doc examples but should be double-checked against the actual server response.

- [ ] **Step 5: Commit**

```bash
git add src/RediStick-TimeSeries/RsRedisEndpoint.extension.st src/RediStick-TimeSeries-Tests/RsTsTest.class.st
git commit -m "Add TS.RANGE aggregation support via tsRange:rangeBy:aggregationBy:using:"
```

---

## Task 6: `RsRedisEndpoint >> tsRevRange:rangeBy:using:` and `tsRevRange:rangeBy:aggregationBy:using:`

**Files:**
- Modify: `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`
- Test: `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st`

**Interfaces:**
- Consumes: `tsRangeFrom:`, `tsRangeArgsFor:key:range:options:aggregation:aggOptions:`, `tsParseRangeSamples:` (Task 4), `RsTsRangeOptions` (Task 2), `RsTsAggregation`/`RsTsAggregationOptions` (Task 3).
- Produces: `RsRedisEndpoint >> tsRevRange:rangeBy:using:`, `tsRevRange:rangeBy:aggregationBy:using:`.

`TS.REVRANGE` shares identical argument grammar with `TS.RANGE` (confirmed against the official docs) — only the command-name token changes and results come back in reverse chronological order. Both new methods simply delegate to the shared private helpers with `'TS.REVRANGE'` as the command name.

- [ ] **Step 1: Write the failing integration tests**

Add to `/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st`:

```
{ #category : 'tests' }
RsTsTest >> testTsRevRangeBasic [
	| key result |
	key := 'test:ts:revrange:basic'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRevRange: key rangeBy: [ :r | r all ] using: nil.
	self assert: result size equals: 3.
	self assert: (result at: 1) key equals: 1020.
	self assert: (result at: 1) value equals: 40.
	self assert: (result at: 3) key equals: 1000
]

{ #category : 'tests' }
RsTsTest >> testTsRevRangeWithCountOption [
	| key result |
	key := 'test:ts:revrange:count'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRevRange: key
		rangeBy: [ :r | r all ]
		using: [ :opts | opts count: 2 ].
	self assert: result size equals: 2.
	self assert: (result at: 1) key equals: 1020.
	self assert: (result at: 2) key equals: 1010
]

{ #category : 'tests' }
RsTsTest >> testTsRevRangeWithAggregation [
	| key result |
	key := 'test:ts:revrange:agg'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 1010 value: 110.
	stick endpoint tsAdd: key timestamp: 1020 value: 120.

	result := stick endpoint
		tsRevRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts | aggs max; bucketDuration: 20 ]
		using: nil.
	self assert: result size equals: 2.
	self assert: (result at: 1) value equals: 120.
	self assert: (result at: 2) value equals: 100
]
```

- [ ] **Step 2: Run to verify it fails**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries-Tests/RsTsTest.class.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsTest'
```
Expected: FAIL — the 3 new tests error with "does not understand `tsRevRange:rangeBy:using:`" / `tsRevRange:rangeBy:aggregationBy:using:`.

- [ ] **Step 3: Add the `tsRevRange:...` implementations**

Add to `/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st`:

```
{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock using: optionsBlock [
	| range options args |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	args := self
		tsRangeArgsFor: 'TS.REVRANGE'
		key: key
		range: range
		options: options
		aggregation: nil
		aggOptions: nil.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
	| range options args aggregation aggOptions |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	aggregation := RsTsAggregation new.
	aggOptions := RsTsAggregationOptions new.
	aggregationBlock value: aggregation value: aggOptions.
	args := self
		tsRangeArgsFor: 'TS.REVRANGE'
		key: key
		range: range
		options: options
		aggregation: aggregation
		aggOptions: aggOptions.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]
```

- [ ] **Step 4: Validate, import, and run the tests**

Run:
```
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/home/mumez/git/RediStick/src/RediStick-TimeSeries/RsRedisEndpoint.extension.st'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-TimeSeries-Tests' path: '/home/mumez/git/RediStick/src'
mcp__smalltalk-interop__run_class_test: 'RsTsTest'
```
Expected: PASS — all `RsTsTest` tests green, including the 3 new ones.

- [ ] **Step 5: Commit**

```bash
git add src/RediStick-TimeSeries/RsRedisEndpoint.extension.st src/RediStick-TimeSeries-Tests/RsTsTest.class.st
git commit -m "Add TS.REVRANGE support via tsRevRange:rangeBy:using: and tsRevRange:rangeBy:aggregationBy:using:"
```

---

## Task 7: Full-suite verification and CLAUDE.local.md status update

**Files:**
- Modify: `/home/mumez/git/RediStick/CLAUDE.local.md`

**Interfaces:**
- Consumes: all classes/methods from Tasks 1-6.
- Produces: nothing new — this task is verification + bookkeeping only.

- [ ] **Step 1: Run the full TimeSeries test packages**

Run:
```
mcp__smalltalk-interop__run_package_test: 'RediStick-TimeSeries-Tests'
```
Expected: all tests pass (existing `RsTsAddOptions`/`RsTsCreateOptions`/`RsTsOptions`-driven tests plus every new test from Tasks 1-6).

- [ ] **Step 2: Run the project-wide CI test groups locally if smalltalkci is available**

Run:
```bash
smalltalkci -s Pharo64-13
```
Expected: green build. If `smalltalkci` is not available in this environment, rely on Step 1's MCP-based verification instead and note that in the commit message.

- [ ] **Step 3: Update `CLAUDE.local.md` to mark Phase 1b TS.RANGE as done**

Read the current `CLAUDE.local.md`, then edit the `### Phase 1b TS.RANGE` heading line to append a status note, e.g. change:
```
### Phase 1b TS.RANGE
```
to:
```
### Phase 1b TS.RANGE — DONE (tsRange:/tsRevRange: with rangeBy:/aggregationBy:/using:, see RediStick-TimeSeries)
```
Leave the rest of the design notes in place as historical record (do not delete the design rationale).

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.local.md
git commit -m "Mark TS.RANGE/TS.REVRANGE phase as complete in TODO notes"
```

---

## Self-Review Notes

- **Spec coverage:** `TS.RANGE` and `TS.REVRANGE` fully covered, including `LATEST`, `FILTER_BY_TS`, `FILTER_BY_VALUE`, `COUNT`, `ALIGN`, `AGGREGATION` (all 15 aggregator tokens), `BUCKETTIMESTAMP`, `EMPTY`. The `rangeBy:`/`aggregationBy:`/`using:` method-variation shape matches the confirmed 案2 decision in `CLAUDE.local.md` and the user's message during planning. `TS.MRANGE`/`FILTER` (label filters) are explicitly out of scope per `CLAUDE.local.md`'s "Phase 2" note.
- **Placeholder scan:** no TBD/placeholder steps; every step has literal file content and exact MCP tool invocations.
- **Type/name consistency:** `tsRangeFrom:`, `tsRangeArgsFor:key:range:options:aggregation:aggOptions:`, and `tsParseRangeSamples:` are defined once (Task 4) and reused verbatim in Tasks 5 and 6 with no renaming drift. `RsTsRange`/`RsTsRangeOptions`/`RsTsAggregation`/`RsTsAggregationOptions` method names are consistent across all task files.
