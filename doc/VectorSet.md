# Working with Vector Sets in RediStick

[RediStick](https://github.com/mumez/RediStick) supports [Redis Vector Sets](https://redis.io/docs/latest/develop/data-types/vector-sets/) - an approximate nearest-neighbor vector data type built into Redis 8.0+.

## Installation

### Installing RediStick VectorSet packages

You can install RediStick VectorSet packages into Pharo (or GemStone/S).

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('VectorSet').
```

If you need tests:

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('VectorSet' 'VectorSetTests').
```

## Basic Usage

### Setting up Connection

```smalltalk
stick := RsRediStick targetUrl: 'sync://localhost'.
stick connect.
```

### Adding Elements (VADD)

```smalltalk
"Add an element with its vector - answers true if newly added,
false if only attributes/vector of an existing element were updated"
stick endpoint vAdd: 'vs:articles' element: 'article1' vector: #(0.12 -0.45 0.33 0.81).

"FP32 form - a ByteArray holding the vector as 32-bit floats in
little-endian byte order, as an alternative to the plain VALUES form"
someLittleEndianFloatBytes := #[143 194 245 61 102 102 230 190 195 245 168 62 41 92 79 63]. "RsVectorSetTestCase fp32BytesFor: #(0.12 -0.45 0.33 0.81)"
stick endpoint vAdd: 'vs:articles' element: 'article2' vectorFp32: someLittleEndianFloatBytes.

"With options by `using:`"
"Note: Some options do not allow you to enter values different from those used when the key was first registered. Therefore, this example uses a new key"
stick endpoint
    vAdd: 'vs:articles:draft' element: 'draft-article1' vector: #(0.10 -0.40 0.30 0.75)
    using: [ :opts |
        opts reduceDim: 2.
        opts cas.
        opts quantizationQ8. "or: opts noQuantization etc."
        opts explorationFactor: 100. "or opts ef: 100"
        opts maxConnections: 8. "or opts m: 8"
        opts setAttr: ({ 'category' -> 'science' } asDictionary) ].

```

### Cardinality, Dimensionality, Embeddings, Removal (VCARD / VDIM / VEMB / VREM)

```smalltalk
stick endpoint vCard: 'vs:articles'.  "2"
stick endpoint vDim: 'vs:articles'.   "4, or nil for a missing key"

"Reconstructed float vector, or nil if the element/key doesn't exist"
stick endpoint vEmb: 'vs:articles' element: 'article1'.
"#(0.12118109315633774 -0.4528346359729767 0.33165356516838074 0.8100000023841858)"

"Raw, quantization-aware fields (VEMB ... RAW)"
stick endpoint vEmb: 'vs:articles' element: 'article1' raw: true.
stick endpoint vEmb: 'vs:articles' element: 'article1' raw: false. "same as vEmb:element:"

"Remove an element - answers true/false"
stick endpoint vRem: 'vs:articles' element: 'article1'.
```

### Set Info (VINFO)

```smalltalk
info := stick endpoint vInfo: 'vs:articles'.
"a Dictionary, or nil for a missing key"
info at: 'size'. "1"
info at: 'vector-dim'. "4"
info at: 'quant-type'. "'int8'"
```

### Attributes (VGETATTR / VSETATTR)

Attributes are arbitrary JSON, converted to/from Smalltalk objects via `STON`.

```smalltalk
"Set attributes - accepts a Smalltalk object (converted to JSON) or a raw JSON String"
stick endpoint vSetAttr: 'vs:articles' element: 'article2' value: ({ 'category' -> 'science' } asDictionary).
stick endpoint vSetAttr: 'vs:articles' element: 'article2' value: '{"category":"science"}'.

"Get attributes - answers a parsed Smalltalk object, or nil if unset/missing"
attr := stick endpoint vGetAttr: 'vs:articles' element: 'article2'.
attr at: 'category'. "'science'"

"SETATTR can also be supplied at VADD time (see above); VGETATTR will see it"
```

### Similarity Search (VSIM)

```smalltalk
"Search by an existing element (ELE form)"
results := stick endpoint vSim: 'vs:articles' queryBy: [ :q | q element: 'article2' ].

"Search by a raw vector (VALUES form)"
results := stick endpoint vSim: 'vs:articles' queryBy: [ :q | q values: #(0.1 -0.4 0.3 0.8) ].

"Search by a raw vector, FP32 form - a ByteArray holding the vector as
32-bit floats in little-endian byte order"
results := stick endpoint vSim: 'vs:articles' queryBy: [ :q | q valuesFp32: someLittleEndianFloatBytes ].

"With options - WITHSCORES, WITHATTRIBS, COUNT, EF, FILTER, FILTER-EF, TRUTH, NOTHREAD"
results := stick endpoint
    vSim: 'vs:articles'
    queryBy: [ :q | q element: 'article2' ]
    using: [ :opts |
        opts withScores.
        opts withAttribs.
        opts count: 5.
        opts explorationFactor: 100.
        opts filterBy: [ :elem | (elem @ 'category') = 'science' ].
        opts maxFilteringEffort: 200.
        opts truth.    "exact linear search instead of approximate HNSW"
        opts noThread ].
```

"Each result is an RsVectorSetSimResult"
results first element. "'article2'" "matched element name"
results first score.   "1" "nil unless WITHSCORES requested"
results first attribs. "a Dictionary ('category' -> 'science')" "nil unless WITHATTRIBS requested"

#### Fluent Filter Expressions (`filterBy:`)

`filterBy:` builds the FILTER string for you instead of writing it by hand.
It evaluates the given block with an `RsVectorSetFilterElement`; sending `@`
with an attribute's dot-path name answers an attribute reference, which
understands the comparison messages `=`, `~=`, `>`, `>=`, `<`, `<=`, and
`in:`. Combine expressions with `&` (AND), `|` (OR), and negate with `not`.

```smalltalk
"Equivalent to opts filter: '.category == \"science\"'"
opts filterBy: [ :elem | (elem @ 'category') = 'science' ].

"Equivalent to opts filter: '.year >= 1980 and .rating > 7'"
opts filterBy: [ :elem |
    ((elem @ 'year') >= 1980) & ((elem @ 'rating') > 7) ].

"Equivalent to opts filter: '.category in [\"science\", \"tech\"] or !(.year < 2000)'"
opts filterBy: [ :elem |
    ((elem @ 'category') in: #('science' 'tech'))
        | ((elem @ 'year') < 2000) not ].
```

See the [expression syntax reference](https://redis.io/docs/latest/develop/data-types/vector-sets/filtered-search/#expression-syntax) for the underlying FILTER grammar.

### Graph Neighbors (VLINKS)

```smalltalk
"Element names directly connected to the given element in the HNSW graph"
links := stick endpoint vLinks: 'vs:articles' element: 'article2'.
"#('article2' 'article3'), or nil for a missing key"

"With scores - an Array of element -> score Associations"
links := stick endpoint vLinks: 'vs:articles' element: 'article2' withScores: true.
links first key.   "element name"
links first value. "similarity score"
```

### Random Members (VRANDMEMBER)

```smalltalk
"A single random element, or nil if the set is empty/missing"
stick endpoint vRandMember: 'vs:articles'.

"count follows Redis VRANDMEMBER semantics as-is: positive count = up to
count distinct elements, negative count = count elements with possible repeats"
stick endpoint vRandMember: 'vs:articles' count: 2.
stick endpoint vRandMember: 'vs:articles' count: -5.
```

### Cleaning Up

```smalltalk
stick endpoint del: #('vs:articles').
```

## References

- [Redis Vector Sets Overview](https://redis.io/docs/latest/develop/data-types/vector-sets/)
- [Redis Vector Set Commands](https://redis.io/docs/latest/commands/redis-8-0-commands/#vector-set-commands)
