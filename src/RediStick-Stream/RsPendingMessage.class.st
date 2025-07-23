Class {
	#name : 'RsPendingMessage',
	#superclass : 'RsStreamObject',
	#instVars : [
		'id',
		'consumerName',
		'millisecondsFromLastDelivery',
		'deliveredCount'
	],
	#category : 'RediStick-Stream',
	#package : 'RediStick-Stream'
}

{ #category : 'accessing' }
RsPendingMessage >> consumerName [

	^ consumerName
]

{ #category : 'accessing' }
RsPendingMessage >> consumerName: anObject [

	consumerName := anObject
]

{ #category : 'accessing' }
RsPendingMessage >> deliveredCount [

	^ deliveredCount
]

{ #category : 'accessing' }
RsPendingMessage >> deliveredCount: anObject [

	deliveredCount := anObject
]

{ #category : 'accessing' }
RsPendingMessage >> id [

	^ id
]

{ #category : 'accessing' }
RsPendingMessage >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
RsPendingMessage >> initFromOrderedCollection: rawValues [
	self id: rawValues first.
	self consumerName: rawValues second.
	self millisecondsFromLastDelivery: rawValues third.
	self deliveredCount: rawValues last.
]

{ #category : 'accessing' }
RsPendingMessage >> millisecondsFromLastDelivery [

	^ millisecondsFromLastDelivery
]

{ #category : 'accessing' }
RsPendingMessage >> millisecondsFromLastDelivery: anObject [

	millisecondsFromLastDelivery := anObject
]

{ #category : 'printing' }
RsPendingMessage >> printOn: aStream [
	aStream nextPutAll: 'id: '.
	self id printOn: aStream.
	aStream cr; nextPutAll: 'consumerName: '.
	self consumerName printOn: aStream.
	aStream cr; nextPutAll: 'millisecondsFromLastDelivery: '.
	self millisecondsFromLastDelivery printOn: aStream.
	aStream cr; nextPutAll: 'deliveredCount: '.
	self deliveredCount printOn: aStream.
]
