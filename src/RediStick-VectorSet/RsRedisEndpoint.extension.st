Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vAdd: key element: element vector: aNumberCollection using: optionsBlock [
	| args options result |
	args := { 'VADD'. key } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsVectorSetAddOptions new.
		optionsBlock value: options.
		options reduceDim ifNotNil: [ :dim | args addAll: { 'REDUCE'. dim } ] ].
	args addAll: { 'VALUES'. aNumberCollection size }.
	args addAll: aNumberCollection.
	args add: element.
	options ifNotNil: [ args addAll: options asArray ].
	result := self unifiedCommand: args.
	^ result = 1
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vCard: key [
	^ self unifiedCommand: { 'VCARD'. key }
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vDim: key [
	^ self unifiedCommand: { 'VDIM'. key }
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vEmb: key element: element [
	| result |
	result := self unifiedCommand: { 'VEMB'. key. element }.
	result ifNil: [ ^ nil ].
	^ (result collect: [ :each | each asNumber ]) asArray
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vEmb: key element: element raw: aBoolean [
	aBoolean ifFalse: [ ^ self vEmb: key element: element ].
	^ self unifiedCommand: { 'VEMB'. key. element. 'RAW' }
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vRem: key element: element [
	^ (self unifiedCommand: { 'VREM'. key. element }) = 1
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vInfo: key [
	| result info |
	result := self unifiedCommand: { 'VINFO'. key }.
	result ifNil: [ ^ nil ].
	info := Dictionary new.
	1 to: result size by: 2 do: [ :i |
		info at: (result at: i) put: (result at: i + 1) ].
	^ info
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vGetAttr: key element: element [
	| result |
	result := self unifiedCommand: { 'VGETATTR'. key. element }.
	result ifNil: [ ^ nil ].
	^ STON fromString: result
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vSetAttr: key element: element value: aJsonableObject [
	| json |
	json := (aJsonableObject isString or: [ aJsonableObject isSymbol ])
		ifTrue: [ aJsonableObject asString ]
		ifFalse: [ STON toJsonString: aJsonableObject ].
	^ (self unifiedCommand: { 'VSETATTR'. key. element. json }) = 1
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vSim: key queryBy: queryBlock [
	^ self vSim: key queryBy: queryBlock using: nil
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vSim: key queryBy: queryBlock using: optionsBlock [
	| query options args result |
	query := RsVectorSetSimQuery new.
	queryBlock value: query.
	options := optionsBlock ifNotNil: [
		| opts | opts := RsVectorSetSimOptions new.
		optionsBlock value: opts.
		opts ].
	args := self vSimArgs: key query: query options: options.
	result := self unifiedCommand: args.
	^ self
		vSimParseResult: result
		withScores: (options notNil and: [ options isWithScores ])
		withAttribs: (options notNil and: [ options isWithAttribs ])
]

{ #category : '*RediStick-VectorSet-private' }
RsRedisEndpoint >> vSimArgs: key query: query options: options [
	"private"
	| args |
	query validate.
	args := { 'VSIM'. key } asOrderedCollection.
	query element
		ifNotNil: [ :element | args addAll: { 'ELE'. element } ]
		ifNil: [
			args addAll: { 'VALUES'. query values size }.
			args addAll: query values ].
	options ifNotNil: [ args addAll: options asArray ].
	^ args
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vLinks: key element: element [
	| result |
	result := self unifiedCommand: { 'VLINKS'. key. element }.
	result ifNil: [ ^ nil ].
	^ (self vLinksFlatten: result) asArray
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vLinks: key element: element withScores: aBoolean [
	| result flat |
	aBoolean ifFalse: [ ^ self vLinks: key element: element ].
	result := self unifiedCommand: { 'VLINKS'. key. element. 'WITHSCORES' }.
	result ifNil: [ ^ nil ].
	flat := self vLinksFlatten: result.
	^ ((1 to: flat size by: 2) collect: [ :i |
		(flat at: i) -> (flat at: i + 1) asNumber ]) asArray
]

{ #category : '*RediStick-VectorSet-private' }
RsRedisEndpoint >> vLinksFlatten: layeredResult [
	"private - VLINKS replies with one sub-array of neighbor entries per HNSW layer"
	| flat |
	flat := OrderedCollection new.
	layeredResult do: [ :layer | flat addAll: layer ].
	^ flat
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vRandMember: key [
	^ self unifiedCommand: { 'VRANDMEMBER'. key }
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vRandMember: key count: n [
	"n follows Redis VRANDMEMBER semantics as-is: positive = up to n distinct
	elements, negative = n elements with possible repeats"
	^ (self unifiedCommand: { 'VRANDMEMBER'. key. n }) asArray
]

{ #category : '*RediStick-VectorSet-private' }
RsRedisEndpoint >> vSimParseResult: rawResult withScores: withScores withAttribs: withAttribs [
	"private"
	| rowSize |
	rawResult ifNil: [ ^ #() ].
	rowSize := 1 + (withScores ifTrue: [ 1 ] ifFalse: [ 0 ]) + (withAttribs ifTrue: [ 1 ] ifFalse: [ 0 ]).
	^ ((1 to: rawResult size by: rowSize) collect: [ :i |
		| element score attribs next |
		element := rawResult at: i.
		next := i + 1.
		score := withScores
			ifTrue: [ (rawResult at: next) ifNotNil: [ :s | s asNumber ] ]
			ifFalse: [ nil ].
		withScores ifTrue: [ next := next + 1 ].
		attribs := withAttribs
			ifTrue: [ (rawResult at: next) ifNotNil: [ :a | STON fromString: a ] ]
			ifFalse: [ nil ].
		RsVectorSetSimResult element: element score: score attribs: attribs ]) asArray
]
