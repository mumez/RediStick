Class {
	#name : 'RsJsonResult',
	#superclass : 'Object',
	#instVars : [
		'key',
		'path',
		'values'
	],
	#category : 'RediStick-Json',
	#package : 'RediStick-Json'
}

{ #category : 'instance creation' }
RsJsonResult class >> key: aKey path: aPath values: valuesArray [
	^ self new
		initializeKey: aKey path: aPath values: valuesArray;
		yourself
]

{ #category : 'comparing' }
RsJsonResult >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ key = anObject key
		and: [ path = anObject path
		and: [ values = anObject values ] ]
]

{ #category : 'accessing' }
RsJsonResult >> first [
	^ self value
]

{ #category : 'testing' }
RsJsonResult >> hasValue [
	"Returns true if the key is valid (regardless of whether values are empty)"
	^ self isInvalidKey not
]

{ #category : 'comparing' }
RsJsonResult >> hash [
	^ key hash bitXor: (path hash bitXor: values hash)
]

{ #category : 'initialization' }
RsJsonResult >> initializeKey: aKey path: aPath values: valuesArray [
	key := aKey.
	path := aPath.
	values := valuesArray
]

{ #category : 'testing' }
RsJsonResult >> isEmpty [
	"Returns true if key is valid but has no values"
	^ self hasValue and: [ values isEmpty ]
]

{ #category : 'testing' }
RsJsonResult >> isInvalidKey [
	"Returns true if the key was invalid (values is nil)"
	^ values isNil
]

{ #category : 'accessing' }
RsJsonResult >> key [
	^ key
]

{ #category : 'accessing' }
RsJsonResult >> path [
	^ path
]

{ #category : 'printing' }
RsJsonResult >> printOn: aStream [
	aStream nextPutAll: 'RsJsonResult('.
	self values printOn: aStream.
	aStream nextPut: $)
]

{ #category : 'accessing' }
RsJsonResult >> value [
	| vals |
	vals := self values.
	vals isEmptyOrNil ifTrue: [^ nil].
	^ vals first
]

{ #category : 'accessing' }
RsJsonResult >> values [
	self isInvalidKey ifTrue: [^ nil].
	^ values
]
