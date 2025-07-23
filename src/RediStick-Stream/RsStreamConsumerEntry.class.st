Class {
	#name : 'RsStreamConsumerEntry',
	#superclass : 'RsStreamObject',
	#instVars : [
		'name',
		'seenTime',
		'activeTime',
		'pelCount',
		'pending'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsStreamConsumerEntry >> activeTime [

	^ activeTime
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> activeTime: anObject [

	activeTime := anObject
]

{ #category : 'initialization' }
RsStreamConsumerEntry >> initFromOrderedCollection: rawValues [
	rawValues pairsDo: [ :key :value | self initVariableAt: key value: value ]
]

{ #category : 'initialization' }
RsStreamConsumerEntry >> initPending: value [
	| pnds |
	pnds := value collect: [ :each |
		        RsStreamPendingEntry fromOrderedCollection: each ].
	self pending: pnds
]

{ #category : 'initialization' }
RsStreamConsumerEntry >> initVariableAt: key value: value [
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'seen-time' ifTrue: [ ^ self seenTime: value ].
	key = 'active-time' ifTrue: [ ^ self activeTime: value ].
	key = 'pel-count' ifTrue: [ ^ self pelCount: value ].
	key = 'pending' ifTrue: [ ^ self initPending: value ].
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> name [

	^ name
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> pelCount [

	^ pelCount
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> pelCount: anObject [

	pelCount := anObject
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> pending [

	^ pending
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> pending: anObject [

	pending := anObject
]

{ #category : 'printing' }
RsStreamConsumerEntry >> printOn: aStream [
	aStream nextPutAll: 'name: '.
	self name printOn: aStream.
	aStream
		cr;
		nextPutAll: 'seenTime: '.
	self seenTime printOn: aStream.
	aStream
		cr;
		nextPutAll: 'activeTime: '.
	self activeTime printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pelCount: '.
	self pelCount printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pending: '.
	self pending printOn: aStream.
	
	
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> seenTime [

	^ seenTime
]

{ #category : 'accessing' }
RsStreamConsumerEntry >> seenTime: anObject [

	seenTime := anObject
]
