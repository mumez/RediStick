Class {
	#name : 'RsStreamReadOptions',
	#superclass : 'Object',
	#instVars : [
		'count',
		'blocking'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'converting' }
RsStreamReadOptions >> asArray [
	| opts |
	opts := {} asOrderedCollection.
	self count ifNotNil: [ :op | opts addAll: {'COUNT'. op} ].
	self blocking ifNotNil: [ :op | opts addAll: {'BLOCK'. op} ].
	^ opts asArray
]

{ #category : 'accessing' }
RsStreamReadOptions >> blocking [

	^ blocking
]

{ #category : 'accessing' }
RsStreamReadOptions >> blocking: anObject [

	blocking := anObject
]

{ #category : 'accessing' }
RsStreamReadOptions >> count [

	^ count
]

{ #category : 'accessing' }
RsStreamReadOptions >> count: anObject [

	count := anObject
]
