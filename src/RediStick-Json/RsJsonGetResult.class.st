Class {
	#name : 'RsJsonGetResult',
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
RsJsonGetResult class >> key: aKey path: aPath values: valuesArray [
	^ self new
		initializeKey: aKey path: aPath values: valuesArray;
		yourself
]

{ #category : 'initialization' }
RsJsonGetResult >> initializeKey: aKey path: aPath values: valuesArray [
	key := aKey.
	path := aPath.
	values := valuesArray
]

{ #category : 'testing' }
RsJsonGetResult >> hasValue [
	"Returns true if the key is valid (regardless of whether values are empty)"
	^ self isInvalidKey not
]

{ #category : 'testing' }
RsJsonGetResult >> isEmpty [
	"Returns true if key is valid but has no values"
	^ self hasValue and: [ values isEmpty ]
]

{ #category : 'testing' }
RsJsonGetResult >> isInvalidKey [
	"Returns true if the key was invalid (values is nil)"
	^ values isNil
]

{ #category : 'accessing' }
RsJsonGetResult >> key [
	^ key
]

{ #category : 'accessing' }
RsJsonGetResult >> path [
	^ path
]

{ #category : 'accessing' }
RsJsonGetResult >> value [
	| vals |
	vals := self values.
	vals isEmptyOrNil ifTrue: [^ nil].
	^ vals first
]

{ #category : 'accessing' }
RsJsonGetResult >> first [
	^ self value
]

{ #category : 'accessing' }
RsJsonGetResult >> values [
	self isInvalidKey ifTrue: [^ nil].
	^ values
]