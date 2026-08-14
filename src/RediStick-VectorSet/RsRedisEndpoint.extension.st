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
