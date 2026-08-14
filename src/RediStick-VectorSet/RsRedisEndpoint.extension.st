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
