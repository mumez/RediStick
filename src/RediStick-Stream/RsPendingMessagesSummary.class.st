Class {
	#name : 'RsPendingMessagesSummary',
	#superclass : 'RsStreamObject',
	#instVars : [
		'size',
		'minId',
		'maxId',
		'consumers'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsPendingMessagesSummary >> consumers [

	^ consumers
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> consumers: anObject [

	consumers := anObject
]

{ #category : 'initialization' }
RsPendingMessagesSummary >> initConsumersFrom: consumerRawValues [
	| consumersDict |
	consumersDict := Dictionary new.
	consumerRawValues ifNotNil: [ :rawValues |
		rawValues do: [ :each |
			consumersDict at: each first put: each last asInteger ] ].
	self consumers: consumersDict
]

{ #category : 'initialization' }
RsPendingMessagesSummary >> initFromOrderedCollection: rawValues [
	self size: rawValues first.
	self minId: rawValues second.
	self maxId: rawValues third.
	self initConsumersFrom: rawValues last.
]

{ #category : 'testing' }
RsPendingMessagesSummary >> isEmpty [
	^ self size = 0
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> maxId [

	^ maxId
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> maxId: anObject [

	maxId := anObject
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> minId [

	^ minId
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> minId: anObject [

	minId := anObject
]

{ #category : 'printing' }
RsPendingMessagesSummary >> printOn: aStream [
	aStream nextPutAll: 'size: '.
	self size printOn: aStream.
	aStream cr; nextPutAll: 'minId: '.
	self minId printOn: aStream.
	aStream cr; nextPutAll: 'maxId: '.
	self maxId printOn: aStream.
	aStream cr; nextPutAll: 'consumers:'.
	self consumers printOn: aStream
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> size [
	^ size
]

{ #category : 'accessing' }
RsPendingMessagesSummary >> size: anObject [

	size := anObject
]
