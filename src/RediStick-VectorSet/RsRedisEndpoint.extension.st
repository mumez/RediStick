Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vAdd: key element: element vector: aNumberCollection [
	^ self vAdd: key element: element vector: aNumberCollection using: nil
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vAdd: key element: element vector: aNumberCollection using: optionsBlock [
	^ self
		vAdd: key
		element: element
		vectorArgs: { 'VALUES'. aNumberCollection size }, aNumberCollection asArray
		using: optionsBlock
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vAdd: key element: element vectorFp32: aByteArray [
	"aByteArray must hold the vector as 32-bit floats in little-endian byte order"
	^ self vAdd: key element: element vectorFp32: aByteArray using: nil
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vAdd: key element: element vectorFp32: aByteArray using: optionsBlock [
	"aByteArray must hold the vector as 32-bit floats in little-endian byte order"
	^ self
		vAdd: key
		element: element
		vectorArgs: { 'FP32'. aByteArray }
		using: optionsBlock
]

{ #category : '*RediStick-VectorSet-private' }
RsRedisEndpoint >> vAdd: key element: element vectorArgs: vectorArgs using: optionsBlock [
	"private - shared by the VALUES and FP32 forms of VADD"
	| args options result |
	args := { 'VADD'. key } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsVectorSetAddOptions new.
		optionsBlock value: options.
		options reduceDim ifNotNil: [ :dim | args addAll: { 'REDUCE'. dim } ] ].
	args addAll: vectorArgs.
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
	^ self vEmbRaw: key element: element
]

{ #category : '*RediStick-VectorSet-private' }
RsRedisEndpoint >> vEmbRaw: key element: element [
	"private - parses the VEMB ... RAW reply into a RsVectorSetRawEmbedding.
	Uses #rawUnifiedCommand: instead of #unifiedCommand: because the
	vector-bytes element (2nd) is a binary bulk string that must not be
	forced through UTF-8 decoding; the other elements arrive as RESP
	simple strings and are already decoded Strings."
	| result |
	result := self rawUnifiedCommand: { 'VEMB'. key. element. 'RAW' }.
	result ifNil: [ ^ nil ].
	^ RsVectorSetRawEmbedding
		quantType: (self vEmbRawElementAsString: (result at: 1))
		bytes: (result at: 2)
		l2Norm: (self vEmbRawElementAsString: (result at: 3)) asNumber
		quantRange: (result size >= 4
			ifTrue: [ (self vEmbRawElementAsString: (result at: 4)) asNumber ]
			ifFalse: [ nil ])
]

{ #category : '*RediStick-VectorSet-private' }
RsRedisEndpoint >> vEmbRawElementAsString: aStringOrByteArray [
	"private - VEMB ... RAW's non-blob elements arrive as RESP simple
	strings (already decoded Strings via #parseSingleLine), but tolerate a
	bulk-string encoding too by decoding ByteArray instances."
	^ aStringOrByteArray isString
		ifTrue: [ aStringOrByteArray ]
		ifFalse: [ self stringFromUtf8Bytes: aStringOrByteArray ]
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
	^ self safeParseJson: result
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vSetAttr: key element: element value: aJsonableObject [
	| json |
	json := (aJsonableObject isString or: [ aJsonableObject isSymbol ])
		ifTrue: [ aJsonableObject asString ]
		ifFalse: [ self toJsonString: aJsonableObject ].
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
			query values
				ifNotNil: [ :values |
					args addAll: { 'VALUES'. values size }.
					args addAll: values ]
				ifNil: [ args addAll: { 'FP32'. query valuesFp32 } ] ].
	options ifNotNil: [ args addAll: options asArray ].
	^ args
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vLinks: key element: element [
	| result |
	result := self unifiedCommand: { 'VLINKS'. key. element }.
	result ifNil: [ ^ nil ].
	^ result flattened
]

{ #category : '*RediStick-VectorSet' }
RsRedisEndpoint >> vLinks: key element: element withScores: aBoolean [
	| result flat |
	aBoolean ifFalse: [ ^ self vLinks: key element: element ].
	result := self unifiedCommand: { 'VLINKS'. key. element. 'WITHSCORES' }.
	result ifNil: [ ^ nil ].
	flat := result flattened.
	^ ((1 to: flat size by: 2) collect: [ :i |
		(flat at: i) -> (flat at: i + 1) asNumber ]) asArray
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
			ifTrue: [ self safeParseJson: (rawResult at: next) ]
			ifFalse: [ nil ].
		RsVectorSetSimResult element: element score: score attribs: attribs ]) asArray
]
