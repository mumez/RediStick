Class {
	#name : 'RsStreamGroupInfo',
	#superclass : 'RsStreamObject',
	#instVars : [
		'name',
		'consumers',
		'pending',
		'lastDeliveredId',
		'entriesRead',
		'lag',
		'pelCount'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsStreamGroupInfo >> consumers [

	^ consumers
]

{ #category : 'accessing' }
RsStreamGroupInfo >> consumers: anObject [

	consumers := anObject
]

{ #category : 'accessing' }
RsStreamGroupInfo >> entriesRead [

	^ entriesRead
]

{ #category : 'accessing' }
RsStreamGroupInfo >> entriesRead: anObject [

	entriesRead := anObject
]

{ #category : 'initialization' }
RsStreamGroupInfo >> initConsumers: value [
	| cons |
	cons := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamConsumerEntry fromOrderedCollection: each ] ].
	self consumers: cons
]

{ #category : 'initialization' }
RsStreamGroupInfo >> initFromOrderedCollection: rawValues [
	rawValues pairsDo: [ :key :value | self initVariableAt: key value: value ]
]

{ #category : 'initialization' }
RsStreamGroupInfo >> initPending: value [
	| pnds |
	pnds := value isInteger
		        ifTrue: [ value ]
		        ifFalse: [
			        value collect: [ :each |
				        RsStreamPendingEntry fromOrderedCollection: each ] ].
	self pending: pnds
]

{ #category : 'initialization' }
RsStreamGroupInfo >> initVariableAt: key value: value [
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'consumers' ifTrue: [ ^ self initConsumers: value ].
	key = 'pending' ifTrue: [ ^ self initPending: value ].
	key = 'last-delivered-id' ifTrue: [ ^ self lastDeliveredId: value ].
	key = 'entries-read' ifTrue: [ ^ self entriesRead: value ].
	key = 'lag' ifTrue: [ ^ self lag:  value ].
	key = 'pel-count' ifTrue: [ ^ self pelCount: value ].
]

{ #category : 'accessing' }
RsStreamGroupInfo >> lag [

	^ lag
]

{ #category : 'accessing' }
RsStreamGroupInfo >> lag: anObject [

	lag := anObject
]

{ #category : 'accessing' }
RsStreamGroupInfo >> lastDeliveredId [

	^ lastDeliveredId
]

{ #category : 'accessing' }
RsStreamGroupInfo >> lastDeliveredId: anObject [

	lastDeliveredId := anObject
]

{ #category : 'accessing' }
RsStreamGroupInfo >> name [

	^ name
]

{ #category : 'accessing' }
RsStreamGroupInfo >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
RsStreamGroupInfo >> pelCount [

	^ pelCount
]

{ #category : 'accessing' }
RsStreamGroupInfo >> pelCount: anObject [

	pelCount := anObject
]

{ #category : 'accessing' }
RsStreamGroupInfo >> pending [

	^ pending
]

{ #category : 'accessing' }
RsStreamGroupInfo >> pending: anObject [

	pending := anObject
]

{ #category : 'printing' }
RsStreamGroupInfo >> printOn: aStream [
	aStream nextPutAll: 'name: '.
	self name printOn: aStream.
	aStream
		cr;
		nextPutAll: 'consumers: '.
	self consumers printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pending: '.
	self pending printOn: aStream.
	aStream
		cr;
		nextPutAll: 'lastDeliveredId: '.
	self lastDeliveredId printOn: aStream.
	aStream
		cr;
		nextPutAll: 'entriesRead: '.
	self entriesRead printOn: aStream.
	aStream
		cr;
		nextPutAll: 'lag: '.
	self lag printOn: aStream
]
