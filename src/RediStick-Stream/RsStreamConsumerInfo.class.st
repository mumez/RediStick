Class {
	#name : 'RsStreamConsumerInfo',
	#superclass : 'RsStreamObject',
	#instVars : [
		'name',
		'pending',
		'idle',
		'inactive'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsStreamConsumerInfo >> idle [

	^ idle
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> idle: anObject [

	idle := anObject
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> inactive [

	^ inactive
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> inactive: anObject [

	inactive := anObject
]

{ #category : 'initialization' }
RsStreamConsumerInfo >> initFromOrderedCollection: rawValues [
	rawValues pairsDo: [ :key :value | self initVariableAt: key value: value ]
]

{ #category : 'initialization' }
RsStreamConsumerInfo >> initVariableAt: key value: value [
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'pending' ifTrue: [ ^ self pending: value ].
	key = 'idle' ifTrue: [ ^ self idle: value ].
	key = 'inactive' ifTrue: [ ^ self inactive: value ]
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> name [

	^ name
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> pending [

	^ pending
]

{ #category : 'accessing' }
RsStreamConsumerInfo >> pending: anObject [

	pending := anObject
]

{ #category : 'printing' }
RsStreamConsumerInfo >> printOn: aStream [
	aStream nextPutAll: 'name: '.
	self name printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pending: '.
	self pending printOn: aStream.
	aStream
		cr;
		nextPutAll: 'idle: '.
	self idle printOn: aStream.
	aStream
		cr;
		nextPutAll: 'inactive: '.
	self inactive printOn: aStream
]
