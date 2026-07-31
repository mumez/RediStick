# Feature: TS.MADD support

## Goal

`RsRedisEndpoint` supports Redis `TS.MADD` (multi-key/multi-value time-series add) through:

- A new `TsMultiValues` class (fluent triplet builder), analogous to `RsJsonMultiSetValues`:
  - `key: key value: value` (implicit timestamp `'*'`)
  - `key: key timestamp: aTimestamp value: value`
  - Class-side factories: `TsMultiValues class >> fromDictionary:`, `fromKeyValues:`, `fromKeyTimestampValues:`
- Endpoint API on `RsRedisEndpoint`:
  - `tsMAdd: tsMultiValues`
  - `tsMAddUsing: tsMultiValuesAddingBlock`
  - `tsMAddWithDictionary:`
  - `tsMAddWithKeyValues:`
  - `tsMAddWithKeyTimestampValues:`
- Full test coverage in `RediStick-TimeSeries-Tests` (`RsTsTest` or a dedicated `TsMultiValues` test class), all green.
- Lint-clean Tonel source following this repo's Smalltalk style guide.

Design references (already fixed by the requester, not open decisions):
- Follow the `RsJsonMultiSetValues` / `jsonMSet:` / `jsonMSetUsing:` pattern in `src/RediStick-Json/RsJsonMultiSetValues.class.st` and `src/RediStick-Json/RsRedisEndpoint.extension.st`.
- Existing `TS.ADD`/`TS.INCRBY`/`TS.DECRBY` implementations in `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st` show the established conventions for this package (timestamp handling via `asRediStickUnixTimestampMillis`, `'*'` for implicit timestamp, `unifiedCommand:`).
- `TS.MADD` Redis command reference: https://redis.io/docs/latest/commands/ts.madd/

## Orchestration Shape

Sequential, single agent (`claude`): plan → implement (TDD) → test → lint & review.

## Working Directory

`/home/mumez/git/RediStick`

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Plan TS.MADD implementation'.
			t prompt: 'You are working in the RediStick Pharo Smalltalk repository (a Redis client). Read CLAUDE.md for repo conventions. We need to add support for the Redis TS.MADD command (https://redis.io/docs/latest/commands/ts.madd/) to the RediStick-TimeSeries package.

Requirements (already decided, do not redesign):
- Create a new class TsMultiValues (in src/RediStick-TimeSeries), mirroring the pattern of RsJsonMultiSetValues (src/RediStick-Json/RsJsonMultiSetValues.class.st): it holds an OrderedCollection of key/timestamp/value triplets and exposes a fluent interface.
- TsMultiValues instance-side fluent methods:
  - key: key value: value  -> adds a triplet with an implicit timestamp of the literal string ''*''
  - key: key timestamp: aTimestamp value: value -> adds a triplet with an explicit timestamp (timestamp may be a raw ms integer or a DateTime; reuse the existing asRediStickUnixTimestampMillis conversion used elsewhere in RediStick-TimeSeries, e.g. in RsRedisEndpoint>>tsAdd:timestamp:value:)
  - Both return self for chaining.
  - An accessor exposing the triplets collection (mirror RsJsonMultiSetValues>>params).
- TsMultiValues class-side factory methods:
  - fromDictionary: aDictionary -> one triplet per key->value association in the dictionary, implicit timestamp
  - fromKeyValues: aCollectionOfKeyValueAssociationsOrPairs -> one triplet per key/value pair, implicit timestamp (accept an Array/OrderedCollection of Associations, e.g. {key1->value1. key2->value2})
  - fromKeyTimestampValues: aCollectionOfTriplets -> one triplet per {key. timestamp. value} triplet already carrying an explicit timestamp
  Each factory returns a populated TsMultiValues instance.
- RsRedisEndpoint extension methods (src/RediStick-TimeSeries/RsRedisEndpoint.extension.st), mirroring jsonMSet:/jsonMSetUsing: (src/RediStick-Json/RsRedisEndpoint.extension.st):
  - tsMAdd: tsMultiValues -> builds a TS.MADD command with repeated key/timestamp/value args from the triplets and sends it via unifiedCommand:. TS.MADD returns one reply array entry per triplet (typically the resulting timestamp per series) -- return that raw result.
  - tsMAddUsing: tsMultiValuesAddingBlock -> creates a TsMultiValues, evaluates the block with it (block receives the TsMultiValues instance as the fluent adder), then calls tsMAdd:
  - tsMAddWithDictionary: aDictionary -> shortcut: tsMAdd: (TsMultiValues fromDictionary: aDictionary)
  - tsMAddWithKeyValues: aCollection -> shortcut: tsMAdd: (TsMultiValues fromKeyValues: aCollection)
  - tsMAddWithKeyTimestampValues: aCollection -> shortcut: tsMAdd: (TsMultiValues fromKeyTimestampValues: aCollection)

Inspect the existing RediStick-TimeSeries and RediStick-Json packages with the smalltalk-interop MCP tools (or by reading the .st files directly) to confirm exact method signatures and helper method names (e.g. asRediStickUnixTimestampMillis, unifiedCommand:) before writing code. Note any series referenced by tsMAdd: must already exist in Redis (create with TS.CREATE first) for a real integration test to succeed -- follow the existing RsTsTest setUp conventions for creating test series.

Produce a concrete, final implementation plan as your reply: exact method signatures for every method above, the exact TS.MADD wire-format argument order (key, timestamp, value repeated per triplet), and a short list of test cases to write (single triplet, multiple triplets, implicit ''*'' timestamp, explicit timestamp, each factory method, each endpoint shortcut method). Do not write code yet.' ].
		builder topicBy: [ :t |
			t title: 'Implement TS.MADD (TDD)'.
			t prompt: 'Follow the plan above to implement TS.MADD support in the RediStick repository at /home/mumez/git/RediStick. Use the smalltalk-dev:smalltalk-developer and smalltalk-dev:test-driven-development conventions: write failing tests first in the RediStick-TimeSeries-Tests package (extend RsTsTest.class.st at src/RediStick-TimeSeries-Tests/RsTsTest.class.st with new test methods, following its existing setUp/dbIndex conventions), then implement:
1. A new Tonel file src/RediStick-TimeSeries/TsMultiValues.class.st defining the TsMultiValues class with the fluent instance methods and class-side factory methods from the plan.
2. New methods appended to src/RediStick-TimeSeries/RsRedisEndpoint.extension.st implementing tsMAdd:, tsMAddUsing:, tsMAddWithDictionary:, tsMAddWithKeyValues:, tsMAddWithKeyTimestampValues:, following the exact style (category tags, argument handling, unifiedCommand: usage) of the neighboring tsAdd:/tsIncrBy: methods already in that file.

Validate every new/edited Tonel file with the smalltalk-validator MCP tools before importing. Import the RediStick-TimeSeries and RediStick-TimeSeries-Tests packages via the smalltalk-interop MCP import_package tool (absolute path /home/mumez/git/RediStick/src), then run the new tests via run_class_test on RsTsTest, iterating until they pass. Use CLAUDE.md''s "Interactive Testing and Debugging" and "Common Pitfalls" sections if you hit serialization or import ordering issues.' .
			t goal: 'TsMultiValues class and all tsMAdd*/tsMAddUsing: endpoint methods are implemented, imported into the running Pharo image, and their new tests pass' ].
		builder topicBy: [ :t |
			t title: 'Run full TimeSeries test suite'.
			t prompt: 'Using the smalltalk-dev:st-test skill (or the smalltalk-interop MCP run_class_test / run_package_test tools), run the complete RediStick-TimeSeries-Tests package test suite (not just the new TS.MADD tests) against the repository at /home/mumez/git/RediStick to confirm the TS.MADD changes introduced no regressions in TS.ADD, TS.ALTER, TS.INCRBY, TS.DECRBY, TS.RANGE, etc. Report the pass/fail counts. If anything fails, fix the root cause in the RediStick-TimeSeries package and re-run until the whole suite is green.' .
			t goal: 'the entire RsTsTest suite (and any other RediStick-TimeSeries-Tests test classes) passes with zero failures and zero errors' ].
		builder topicBy: [ :t |
			t title: 'Lint and style review'.
			t prompt: 'Review the Tonel files changed for TS.MADD support in /home/mumez/git/RediStick (src/RediStick-TimeSeries/TsMultiValues.class.st, src/RediStick-TimeSeries/RsRedisEndpoint.extension.st, and the RsTsTest.class.st test additions). Use the smalltalk-dev:st-lint skill (or the smalltalk-validator MCP lint_tonel_smalltalk_from_file tool) on each changed file, and check them against the smalltalk-dev:smalltalk-developer skill''s Pharo style-guide conventions (method categorization, class comment presence, naming). Fix every lint finding and style-guide deviation you find directly in the source, re-validate, and re-import/re-test via smalltalk-interop MCP tools to confirm nothing broke.' .
			t goal: 'lint clean and style-guide issues fixed' ]
	} agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'TS.MADD orchestration done: ' , orc result ].
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:` runs the orchestration in the background and returns immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript), or check progress with `AbBaseOrchestration allSubInstances detect: [ :each | each isRunning ] ifNone:[]`.
