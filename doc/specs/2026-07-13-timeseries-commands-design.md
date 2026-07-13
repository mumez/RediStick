# RediStick-TimeSeries: TS.* Commands Support Design

## Background / Goal
Support Redis 8 Time Series commands (`TS.*`) in RediStick.
The implementation follows the pattern established by the existing `RediStick-Json` package
(`RsRedisEndpoint` extension + options classes).

Reference: https://redis.io/docs/latest/commands/redis-8-0-commands/#time-series-commands

## Implementation Reference Rule
- When editing `.st` files, always consult the `smalltalk-dev:smalltalk-developer` skill.
  In particular, follow its Tonel style guide and implementation patterns
  (it also includes a worked example of the Options pattern used in this design).
- Look up the exact API spec for each command on the web at implementation time
  (e.g. TS.ADD → https://redis.io/docs/latest/commands/ts.add/).

## 1. Architecture

### Package Structure
- `RediStick-TimeSeries`: main package (extension of `RsRedisEndpoint`, same shape as `RediStick-Json`)
- `RediStick-TimeSeries-Tests`: test package

### Baseline / CI Changes
Add the following to `BaselineOfRediStick`:
```
spec package: 'RediStick-TimeSeries' with: [
        spec requires: #('RediStick-Core')].
spec package: 'RediStick-TimeSeries-Tests' with: [
        spec requires: #('RediStick-Tests' 'RediStick-TimeSeries')].

spec
    group: 'TimeSeries' with: #('RediStick-TimeSeries');
    group: 'TimeSeriesTests' with: #('RediStick-TimeSeries-Tests').
```
Add `TimeSeriesTests` to the `load:` list in `.smalltalk.ston`.

## 2. Common Implementation Conventions

### Method Signatures
- Required arguments are passed as ordinary keyword arguments (e.g. `tsCreate: key`).
- Commands with many options use the `using: optionsBlock` form, e.g. the same pattern as
  `RsRedisEndpoint >> jsonArrPop: key path: path using: optionsBlock`.
- Options classes are named `RsTs<Command>Options`, and like `RsJsonArrOptions` are simple
  `Object` subclasses with accessor methods plus an `asArray` method (conversion to a Redis
  argument array).

### Timestamp Handling
- Add `Integer >> asUnixTimestampValue` as an extension method: `^ self` (returned as-is)
- Add `DateAndTime >> asUnixTimestampValue` as an extension method: converts to a millisecond
  epoch integer
- When the timestamp argument is `nil`, treat it as auto-assignment (`'*'`)
- Each command provides a base form and an auto variant. For example:
  - `tsAdd: key timestamp: tsMSecsOrDateTime value: value` — base form (`timestamp` may be `nil`)
  - `tsAdd: key value: value` — auto variant; internally calls
    `self tsAdd: key timestamp: nil value: value`

### Labels / Tags Handling
- Accept either a `Dictionary` or an array of `Association`s
- Internally convert to a `Dictionary` via `asDictionary`, then use the existing
  `RsRedisEndpoint >> flattenedKeysAndValuesFrom:` to build the
  `LABELS key1 val1 key2 val2 ...` argument array

### Result Value Conversion
- Attempt to parse string-typed numeric results with `NumberParser parse:onError:`
- If parsing fails, return the original string value as-is (to handle the rare case of a
  non-numeric label value)

### Query Result Representation
- `[timestamp, value]` pairs returned by `TS.GET` / `TS.RANGE` etc. are represented as an array
  of `Association`s (`timestamp -> value`), without introducing a dedicated result-wrapper class

## 3. Phase Plan

### Phase 1a (highest priority — basic operations)
- `TS.CREATE`, `TS.ADD`, `TS.DEL`, `TS.GET`

### Phase 1b (remaining basic operations)
- `TS.MADD`, `TS.INCRBY`, `TS.DECRBY`, `TS.ALTER`, `TS.RANGE`, `TS.REVRANGE`, `TS.INFO`

### Phase 2 (multi-series queries + aggregation)
- `TS.MGET`, `TS.MRANGE`, `TS.MREVRANGE`, `TS.QUERYINDEX`
- Full support for aggregation options (`AGGREGATION`, `BUCKETDURATION`, etc.) via options classes

### Phase 3 (downsampling rules and other admin commands)
- `TS.CREATERULE`, `TS.DELETERULE`

Each phase is implemented, tested, and verified independently before moving to the next.

## 4. Testing Approach
- Introduce an `RsTsTest` class (subclassing `RsRedisTestCase`), aiming for coverage on par with
  the existing `RsJsonTest`
- Add tests as each phase is implemented, verifying with the smalltalk-interop
  MCP's `run_class_test` at each step
- Use `RsRedisTestCase dbIndex` for test keys, avoiding conflicts with other packages' tests, as
  is done elsewhere in the codebase

## Out of Scope
- Any other TS-family admin commands not covered by the phases above will be planned as a
  follow-up phase separately
