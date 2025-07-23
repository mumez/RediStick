Class {
	#name : 'RsStreamConsumerGroupBasePoller',
	#superclass : 'RsStreamBasePoller',
	#instVars : [
		'consumer',
		'shouldDeleteEntryAfterAcceptance'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'instance creation' }
RsStreamConsumerGroupBasePoller class >> on: aStreamConsumer [
	^ self new initConsumer: aStreamConsumer; yourself
]

{ #category : 'private' }
RsStreamConsumerGroupBasePoller >> basicPoll [
	^ self pollNeverDelivered.
]

{ #category : 'accessing' }
RsStreamConsumerGroupBasePoller >> consumer [

	^ consumer
]

{ #category : 'accessing' }
RsStreamConsumerGroupBasePoller >> consumer: anObject [

	consumer := anObject
]

{ #category : 'handling' }
RsStreamConsumerGroupBasePoller >> handleReceived: receivedEntry [
	super handleReceived: receivedEntry.
	self shouldDeleteEntryAfterAcceptance ifTrue: [ self stream deleteAt: receivedEntry id ]
]

{ #category : 'initialization' }
RsStreamConsumerGroupBasePoller >> initConsumer: aStreamConsumer [
	consumer := aStreamConsumer sameNameAndGrouped
]

{ #category : 'private' }
RsStreamConsumerGroupBasePoller >> pollNeverDelivered [

	self subclassResponsibility 
]

{ #category : 'private' }
RsStreamConsumerGroupBasePoller >> refresh [
	self refreshConsumer
]

{ #category : 'initialization' }
RsStreamConsumerGroupBasePoller >> refreshConsumer [
	consumer := consumer sameNameAndGrouped
]

{ #category : 'accessing' }
RsStreamConsumerGroupBasePoller >> shouldDeleteEntryAfterAcceptance [
	^ shouldDeleteEntryAfterAcceptance ifNil: [ shouldDeleteEntryAfterAcceptance := false ]
]

{ #category : 'accessing' }
RsStreamConsumerGroupBasePoller >> shouldDeleteEntryAfterAcceptance: aBoolean [
	shouldDeleteEntryAfterAcceptance := aBoolean 
]

{ #category : 'accessing' }
RsStreamConsumerGroupBasePoller >> stick [
	^ self stream stick
]

{ #category : 'accessing' }
RsStreamConsumerGroupBasePoller >> stream [
	^self consumer stream
]
