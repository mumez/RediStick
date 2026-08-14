# Vector Sets API Implementation Plan

**Goal:** Add full support for Redis 8.0's Vector Set data type (`VADD`, `VSIM`, `VREM`,
`VCARD`, `VDIM`, `VEMB`, `VGETATTR`, `VSETATTR`, `VLINKS`, `VRANDMEMBER`, `VINFO`) to
RediStick, as a new optional module following the same conventions already established
by `RediStick-TimeSeries`, `RediStick-Search`, and `RediStick-Json`.

**References:**
- https://redis.io/docs/latest/commands/redis-8-0-commands/#vector-set-commands
- https://redis.io/docs/latest/commands/vadd/, `/vsim/`, `/vrem/`, `/vcard/`, `/vdim/`,
  `/vemb/`, `/vgetattr/`, `/vsetattr/`, `/vlinks/`, `/vrandmember/`, `/vinfo/`

## Design Principles (from `CLAUDE.local.md`)

- Follow the `RediStick-TimeSeries` design conventions:
  - Required arguments stay as plain keyword parameters on `RsRedisEndpoint`.
  - Commands with many optional parameters use the `using: [:opts | ...]` block
    pattern, backed by a dedicated `Object` subclass with one accessor per option
    and an `asArray` method that emits the Redis argument fragment in protocol order
    (mirrors `RsTsAddOptions`, `RsTsRangeOptions`, `RsSearchCreateIndexOptions`, etc.).
  - Commands whose replies are structurally rich get a dedicated result/value class
    instead of returning raw arrays/dictionaries (mirrors `RsTsRangeValue`,
    `RsTsGroupedRangeValue`, `RsSearchResult`/`RsSearchResultSet`).
  - TDD throughout: write a failing SUnit test first, then implement, matching the
    `RsTsRange`/`RsTsRangeOptions` task pattern in
    `doc/plans/2026-07-15-ts-range-implementation.md`.
- Vectors used in tests come from a **fixture method** returning precomputed constant
  vectors (e.g. `RsVectorSetTestCase class >> sampleEmbeddingFor:`/similar), not from
  live Ollama calls, since embedding generation is slow. Ollama (`OllamaClient`,
  available in the dev image) is only used once, offline, to *produce* the fixture
  constants — it is never called from the test suite itself.
- Implement incrementally, most important commands first, each phase independently
  shippable and merge-able.

## Package Structure

New packages, following the `RediStick-TimeSeries` / `RediStick-TimeSeries-Tests` shape:

- `RediStick-VectorSet` — production code, depends on `RediStick-Core`.
- `RediStick-VectorSet-Tests` — tests, depends on `RediStick-Tests` and
  `RediStick-VectorSet`.

`BaselineOfRediStick` additions (mirrors the `TimeSeries` block):
```
spec package: 'RediStick-VectorSet' with: [
        spec requires: #('RediStick-Core')].
spec package: 'RediStick-VectorSet-Tests' with: [
        spec requires: #('RediStick-Tests' 'RediStick-VectorSet')].

spec
    group: 'VectorSet' with: #('RediStick-VectorSet');
    group: 'VectorSetTests' with: #('RediStick-VectorSet-Tests').
```
`.smalltalk.ston` `#load` list gains `'VectorSetTests'`.

## Command Inventory & Phase Assignment

| Command | Purpose | Phase |
|---|---|---|
| `VADD` | Add/update an element with its vector | 1 |
| `VCARD` | Cardinality of the set | 2 |
| `VDIM` | Vector dimensionality | 2 |
| `VEMB` | Retrieve an element's vector | 2 |
| `VREM` | Remove an element | 2 |
| `VINFO` | Set metadata (HNSW params, quantization, etc.) | 2 |
| `VGETATTR` | Read an element's JSON attributes | 3 |
| `VSETATTR` | Set/replace an element's JSON attributes | 3 |
| `VSIM` | Similarity search (by element or raw vector) | 4 |
| `VLINKS` | Inspect HNSW graph neighbors of an element | 5 |
| `VRANDMEMBER` | Random element(s) from the set | 5 |

Rationale for ordering: `VADD` unlocks everything else and is the most complex write
path (quantization, reduction, CAS, build params) — worth isolating in its own phase.
Phase 2 gives a minimally useful read/write round trip. Phase 3 (attributes) is
self-contained and low-risk. Phase 4 (`VSIM`) is the headline read feature and the
most complex reply shape, so it comes after the simpler pieces are proven. Phase 5
covers the two "nice to have" introspection/sampling commands.

---

## Phase 0 — Scaffolding & Test Fixtures

**Deliverables:**
- `RediStick-VectorSet` / `RediStick-VectorSet-Tests` packages created (`package.st`
  only, no classes yet) and registered in `BaselineOfRediStick` + `.smalltalk.ston`.
- `RsVectorSetTestCase` (subclass of `RsRedisTestCase`, same shape as `RsTsTest`'s
  setup) with a fixture accessor, e.g.:
  ```smalltalk
  RsVectorSetTestCase class >> sampleVectorA
      "Precomputed embedding, generated once via OllamaClient qwen3-embedding:4b
       for 'The sky is blue because of Rayleigh scattering'. Kept as a literal so
       tests don't depend on a live Ollama server."
      ^ #(0.0123 -0.0456 ... )
  ```
  Two or three short fixture vectors (small dimensionality, e.g. 4-8 floats) are
  enough for protocol-level tests — real embedding dimensionality is not required to
  exercise `VADD`/`VSIM` argument building and reply parsing.
- Empty-but-passing test run to confirm package wiring (`mcp__smalltalk-interop__run_package_test: 'RediStick-VectorSet-Tests'`).

**Exit criteria:** package loads via Metacello group `VectorSet`/`VectorSetTests`,
CI config recognizes the new test group.

---

## Phase 1 — `VADD` (write path)

**Redis syntax:**
```
VADD key [REDUCE dim] (FP32 blob | VALUES num val1 val2 ...) element
     [CAS] [NOQUANT | Q8 | BIN] [EF exploration-factor]
     [SETATTR json] [M numlinks]
```

**Classes:**
- `RsVectorSetAddOptions` — instance vars for `reduceDim`, `cas` (flag), `quantization`
  (`#noQuant`/`#q8`/`#bin`/nil), `ef`, `setAttr` (JSON string or Smalltalk
  object auto-converted via `STON toJsonString:`, avoiding any dependency on
  NeoJSON), `m` (numlinks). `asArray`
  emits tokens in the order Redis expects, empty array when nothing is set.

**Endpoint methods (`RsRedisEndpoint.extension.st` in `RediStick-VectorSet`):**
```
vAdd: key element: element vector: aFloatCollection using: optionsBlock
```
- Accepts a plain `Collection` of numbers for the vector (sent as `VALUES n v1 v2 ...`);
  `FP32` binary form is deferred (note as a follow-up, not required for v1 unless
  trivial to add alongside).
- Returns a `Boolean` (Redis replies `1`/`0` for added/updated-only-attrs).

**Tests:** argument-building tests for `RsVectorSetAddOptions` (no Redis needed) +
integration tests in `RsVectorSetTest` covering: add without options, add with
`REDUCE`, add with `CAS`, add with quantization variants, add with `SETATTR`, add with
`M`/`EF`, re-adding the same element (update path).

---

## Phase 2 — Core read/write: `VCARD`, `VDIM`, `VEMB`, `VREM`, `VINFO`

**Redis syntax:**
```
VCARD key
VDIM key
VEMB key element [RAW]
VREM key element
VINFO key
```

**Classes:**
- `RsVectorSetInfo` — value class wrapping the `VINFO` reply (a flat field/value
  array like `TS.INFO`'s reply, e.g. quant-type, dimensionality, size,
  max-level, vector-dim, hnsw-m, ...). Same shape as how `tsInfo:` currently returns
  a `Dictionary` in `RediStick-TimeSeries` — decide during implementation whether a
  `Dictionary` (simplest, consistent with `tsInfo:`) or a small value object is
  warranted; default to `Dictionary` unless VINFO has fields that need type
  conversion/derived accessors.
- `VEMB ... RAW` returns quantization-aware raw fields; plain `VEMB` returns a
  reconstructed float array — `vEmb:element:` returns an `Array` of `Float`s by
  default, with a `vEmb:element:raw:` (or `using:`) variant for the raw form.

**Endpoint methods:**
```
vCard: key
vDim: key
vEmb: key element: element
vEmb: key element: element raw: aBoolean
vRem: key element: element
vInfo: key
```

**Tests:** integration tests building on Phase 1's `vAdd:element:vector:using:` to
seed data, then asserting cardinality/dimension/embedding-roundtrip/removal/info
fields.

---

## Phase 3 — Attributes: `VGETATTR`, `VSETATTR`

**Redis syntax:**
```
VGETATTR key element
VSETATTR key element json
```

**Design:** Attributes are arbitrary JSON. Use `STON toJsonString:`/`STON
fromJsonString:` for the Smalltalk-object <-> JSON conversion (STON is a core Pharo
class, already used by `RsVectorSetAddOptions#setAttr`), so `RediStick-VectorSet`
has no dependency on `RediStick-Json` or NeoJSON (which merely happens to be present
in the dev image). `vGetAttr:element:` returns a parsed Smalltalk object
(Dictionary/Array/etc.) or `nil` if unset; `vSetAttr:element:value:` accepts a
Smalltalk object or raw JSON string.

**Endpoint methods:**
```
vGetAttr: key element: element
vSetAttr: key element: element value: aJsonableObject
```

**Tests:** set/get roundtrip with a nested dictionary attribute, get on element with
no attributes (`nil`), overwrite existing attributes, set via `SETATTR` at `VADD` time
(Phase 1) then confirm `VGETATTR` sees it.

---

## Phase 4 — `VSIM` (similarity search)

**Redis syntax:**
```
VSIM key (ELE element | FP32 blob | VALUES num val1 val2 ...)
     [WITHSCORES] [WITHATTRIBS] [COUNT num] [EF search-exploration-factor]
     [FILTER expression] [FILTER-EF max-filtering-effort] [TRUTH] [NOTHREAD]
```

**Classes:**
- `RsVectorSetSimQuery` — value object representing the query subject: `element:`,
  `values:` (Collection of numbers), possibly `fp32:` later. Analogous role to
  `RsTsRange` (a small "what am I querying" value object passed into a block).
- `RsVectorSetSimOptions` — `withScores` (flag), `withAttribs` (flag), `count:`,
  `ef:`, `filter:` (raw filter-expression string), `filterEf:`, `truth` (flag),
  `noThread` (flag). `asArray` in protocol order.
- `RsVectorSetSimResult` — one row of the reply: `element`, `score` (nil unless
  `WITHSCORES`), `attribs` (nil unless `WITHATTRIBS`, parsed JSON). Mirrors
  `RsTsValue`/`RsSearchResult`.

**Endpoint method:**
```
vSim: key queryBy: [:query | query element: 'foo'] using: optionsBlock
```
(or `vSim: key queryBy: [:query | query values: #(...)] using: optionsBlock` — the block
receives the query-subject value object, matching the `rangeBy:` idiom from
TimeSeries). Returns an `Array` of `RsVectorSetSimResult` when `WITHSCORES`/
`WITHATTRIBS` requested, or a plain `Array` of element-name Strings for the bare case
— decide based on what keeps the common case ergonomic; likely always return
`RsVectorSetSimResult` array for consistency (simpler mental model, minor overhead).

**Tests:** search by `ELE`, search by `VALUES`, `COUNT` limiting, `WITHSCORES`,
`WITHATTRIBS`, `FILTER` expression, combined options. Use Phase 0 fixture vectors to
seed a small set (3-5 elements) so nearest-neighbor ordering is deterministic enough
to assert on.

---

## Phase 5 — `VLINKS`, `VRANDMEMBER`

**Redis syntax:**
```
VLINKS key element [WITHSCORES]
VRANDMEMBER key [count]
```

**Design:** Both are simple enough not to need new value classes.
- `vLinks: key element: element` → `Array` of element-name Strings.
- `vLinks: key element: element withScores: true` → `Array` of `Association`s
  (element -> score), consistent with how `tsGet:` returns an `Association`.
- `vRandMember: key` → single element String or `nil` if the set is empty.
- `vRandMember: key count: n` → `Array` of Strings (Redis semantics: positive count =
  up to n distinct elements, negative count = n elements with possible repeats — pass
  through as-is, document the Redis semantics rather than reimplementing them).

**Tests:** links on a populated set (with/without scores), rand member single form,
rand member with positive/negative count, edge case on an empty/absent key.

---

## Phase 6 — Documentation & Polish

- Write `doc/VectorSet.md` (mirrors `doc/TimeSeries.md` structure: installation,
  connection setup, per-command usage examples, references section).
- Update root `README.md`'s module list / `.smalltalk.ston` if a top-level mention of
  available groups exists there.
- Sweep all phases for consistent naming (`vAdd:`/`vSim:`/... prefix, `using:` block
  idiom) and re-run the full `RediStick-VectorSet-Tests` suite plus a full
  `smalltalkci` run before considering the module complete.
- Revisit deferred items called out during earlier phases (e.g. `FP32` binary vector
  input for `VADD`/`VSIM`) and decide whether to implement or explicitly drop them.

---

## Sequencing Notes

- Each phase should land as its own PR/commit set, following the TDD task-by-task
  style already demonstrated in `doc/plans/2026-07-15-ts-range-implementation.md` —
  write the failing test, validate + import via the smalltalk-interop/validator MCP
  tools, implement, re-run, commit.
- Phases 2 and 3 have no dependency on each other and could be reordered or done in
  parallel if useful; Phase 4 depends on Phase 1 (needs data to search) and benefits
  from Phase 3's JSON-conversion helper (for `WITHATTRIBS`); Phase 5 has no hard
  dependency beyond Phase 1 (needs data to link/sample).
- Before starting Phase 1, confirm exact `VADD` reply semantics and quantization
  token spelling against a live Redis 8.0+ instance (`VSIM`/`VADD` are newer commands
  with less community documentation than TimeSeries/Search commands already in this
  codebase) — do this via `mcp__smalltalk-interop__eval` raw command round-trips
  before writing the Options class, same caution already noted in the TS.RANGE plan's
  self-review for boundary-value behavior.
