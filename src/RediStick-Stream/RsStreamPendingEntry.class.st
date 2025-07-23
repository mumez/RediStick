Class {
	#name : 'RsStreamPendingEntry',
	#superclass : 'RsStreamObject',
	#instVars : [
		'id',
		'owner',
		'deliveredTimestamp',
		'deliveredCount'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsStreamPendingEntry >> deliveredCount [

	^ deliveredCount
]

{ #category : 'accessing' }
RsStreamPendingEntry >> deliveredCount: anObject [

	deliveredCount := anObject
]

{ #category : 'accessing' }
RsStreamPendingEntry >> deliveredTimestamp [

	^ deliveredTimestamp
]

{ #category : 'accessing' }
RsStreamPendingEntry >> deliveredTimestamp: anObject [

	deliveredTimestamp := anObject
]

{ #category : 'accessing' }
RsStreamPendingEntry >> id [

	^ id
]

{ #category : 'accessing' }
RsStreamPendingEntry >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
RsStreamPendingEntry >> initFromOrderedCollection: rawValues [
	rawValues size = 3 ifTrue: [
		self id: (rawValues at: 1).
		self deliveredTimestamp: (rawValues at: 2).
		^ self deliveredCount: (rawValues at: 3) ].
	
	self id: (rawValues at: 1).
	self owner: (rawValues at: 2).
	self deliveredTimestamp: (rawValues at: 3).
	self deliveredCount: (rawValues at: 4)
]

{ #category : 'accessing' }
RsStreamPendingEntry >> owner [

	^ owner
]

{ #category : 'accessing' }
RsStreamPendingEntry >> owner: anObject [

	owner := anObject
]

{ #category : 'printing' }
RsStreamPendingEntry >> printOn: aStream [
	aStream nextPutAll: 'id: '.
	self id printOn: aStream.
	aStream
		cr;
		nextPutAll: 'owner: '.
	self owner printOn: aStream.
	aStream
		cr;
		nextPutAll: 'deliveredTimestamp: '.
	self deliveredTimestamp printOn: aStream.
	aStream
		cr;
		nextPutAll: 'deliveredCount: '.
	self deliveredCount printOn: aStream
]
