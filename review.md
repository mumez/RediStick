# TimeSeries Branch Review — SUGGESTION Notes

Review of `mumez/time` vs `origin/develop` (Phase 1a Time Series support).
WARNING findings have been fixed in code; the following SUGGESTION items are
parked for follow-up work (Phase 1b/2/3 or a dedicated cleanup PR).

## SUGGESTION findings (not fixed)

### 1. `tsAdd: key value: value using:` and the `LATEST` branch of `tsGet: key latest:`
- File: `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st:36-38, 78-88`
- The `tsAdd: value: using:` auto-timestamp-with-options variant is added but
  has no caller or test in the diff. Either delete it or add a test that
  exercises auto-timestamp + options together.
- The `aBoolean ifTrue: [ args add: 'LATEST' ]` branch in `tsGet: key latest:`
  is exercised only via `latest: false` (from the public `tsGet: key`).
  Add a test for `tsGet: key latest: true` on a series with multiple
  buckets, or inline the `false` call and drop the parameter.

### 2. `RsTsAddOptions` / `RsTsCreateOptions` near-clone drift risk
- Files: `src/RediStick-TimeSeries/RsTsAddOptions.class.st`,
  `src/RediStick-TimeSeries/RsTsCreateOptions.class.st`
- Both classes declare the same 4 shared instVars
  (`retention`, `encoding`, `chunkSize`, `labels`) and emit the same
  `RETENTION` / `ENCODING` / `CHUNK_SIZE` keywords from `asArray`.
  Only the policy field name (`onDuplicate` vs `duplicatePolicy`) and
  emitted keyword (`ON_DUPLICATE` vs `DUPLICATE_POLICY`) differ.
- Future options added to one class are likely to be forgotten on the
  other, producing inconsistent option coverage between `TS.ADD` and
  `TS.CREATE`.
- Suggested refactor: introduce `RsTsOptions` superclass holding
  `retention`, `encoding`, `chunkSize`, `labels` + the shared `asArray`
  emission. Subclasses add only the policy field and override `asArray`
  to append the policy keyword.

### 3. `LABELS k v ...` tail copy-pasted in `tsAdd:...using:` and `tsCreate:...using:`
- File: `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st:23-25, 55-57`
- Same 3-line block in two places: append `'LABELS'` then
  `flattenedKeysAndValuesFrom: options labels`. Local drift hazard in a
  94-line file.
- Suggested refactor: move the labels emission into the options class
  so `options asArray` returns the full trailing sequence (including
  `LABELS k v ...`), and have both endpoint methods just do
  `args addAll: options asArray`.

### 4. `DateAndTime >> asRediStickUnixTimestampMillis` performance
- File: `src/RediStick-TimeSeries/DateAndTime.extension.st:5`
- Current implementation uses Integer arithmetic
  (`(self - DateAndTime epoch) asMilliSeconds`), so the original Float
  round-trip performance concern is largely addressed.
- However, the new method also benefits from being on the DateAndTime
  receiver itself — for high-frequency ingest the receiver re-derives
  the Julian/seconds pair on every call. If profiling shows a hot path,
  consider caching the result on the receiver or precomputing the millis
  in the construction path.

### 5. `tsParseValue:` silently returns a String on parse failure
- File: `src/RediStick-TimeSeries/RsRedisEndpoint.extension.st:91-94`
- The design doc justifies the fallback as handling non-numeric label
  values, but the method is only called on `result second` (the sample
  value of `TS.GET`) in the diff — never on labels. The fallback only
  ever activates on actual parse errors and would silently corrupt
  downstream arithmetic.
- Suggested fix: drop the `onError:` fallback (let `NumberParser` raise)
  or restrict it to a dedicated `tsParseLabelValue:` helper used by the
  planned `TS.INFO` / `TS.RANGE` paths. If a non-numeric label case
  really needs to be supported, add a separate helper for that.

### 6. Extension selector name conflict risk (partially addressed by rename)
- Files: `src/RediStick-TimeSeries/DateAndTime.extension.st:5`,
  `src/RediStick-TimeSeries/Integer.extension.st:5`
- The selector was renamed from `asUnixTimestampValue` to
  `asRediStickUnixTimestampMillis` to encode the unit explicitly and
  reduce the chance of collision with other libraries under
  `.smalltalk.ston`'s `#useLoaded` policy.
- If other RediStick packages or sister projects define similarly
  generic extensions, the safer long-term move is to move
  `asRediStickUnixTimestampMillis` into a shared `RediStick-Core`
  extension to control its definition and ownership.

## Additional deployment-safety notes (informational)

- `README.md` does not mention the new `RediStick-TimeSeries` package.
  Users who only read the README will not know the package exists, and
  the Phase 1a-only scope (TS.CREATE / TS.ADD / TS.DEL / TS.GET) is
  undocumented for end users. Plan to add a "With TimeSeries package"
  Metacello example and a usage snippet covering `tsCreate:` /
  `tsAdd: value:` / `tsGet:` in a follow-up.
- `doc/specs/2026-07-13-timeseries-commands-design.md` describes
  unimplemented Phase 1b/2/3 commands (`tsMAdd:`, `tsRange:`,
  `tsIncrBy:`, `tsCreateRule:`, etc.) as if they were committed. Add a
  "Status" line near the top stating that only Phase 1a is currently
  implemented, and move the future-phase section under a
  "## Planned (not yet implemented)" heading.

## Performance / dead-code findings dropped after filter

- `asOrderedCollection` from a literal Array
  (`RsRedisEndpoint.extension.st:14-18, 48-50, 80-82`) — micro-optimization,
  the `unifiedCommand:` layer already does its own conversion. Not worth
  flagging.
- `tsDel:from:to:` calling `asUnixTimestampValue` twice on different
  receivers — caching would not help (different receivers).
- `flattenedKeysAndValuesFrom:` in `RediStick-Core` — code not in this
  diff, out of scope per review rules.

## Verification

- All 12 `RsTsTest` tests pass after the WARNING fixes.
- Modified files: `RsTsTest.class.st`, `DateAndTime.extension.st`,
  `Integer.extension.st`, `RsRedisEndpoint.extension.st`.
