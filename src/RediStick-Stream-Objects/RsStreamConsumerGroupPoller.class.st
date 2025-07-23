Class {
	#name : 'RsStreamConsumerGroupPoller',
	#superclass : 'RsStreamConsumerGroupBasePoller',
	#instVars : [
		'shouldAutoClaimBlock',
		'claimMinIdleMilliseconds',
		'lastClaimTimestamp'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'claiming' }
RsStreamConsumerGroupPoller >> autoClaimEvery: aDulation [
	self updateLastClaimTimestamp.
	self autoClaimIfTrue: [ :c | (DateAndTime now - c lastClaimTimestamp) >= aDulation ]
]

{ #category : 'claiming' }
RsStreamConsumerGroupPoller >> autoClaimIfTrue: aBlock [
	self shouldAutoClaimBlock: aBlock
]

{ #category : 'private' }
RsStreamConsumerGroupPoller >> basicPoll [
	| entries |
	entries := OrderedCollection new.
	self shouldAutoClaim ifTrue: [ 
		self claimPending
	].
	entries addAll: self pollPending.
	entries addAll: self pollNeverDelivered.
	^ entries
]

{ #category : 'accessing' }
RsStreamConsumerGroupPoller >> claimMinIdleMilliseconds [

	^ claimMinIdleMilliseconds ifNil: [ claimMinIdleMilliseconds := self settings claimMinIdleMilliseconds ]
]

{ #category : 'accessing' }
RsStreamConsumerGroupPoller >> claimMinIdleMilliseconds: anObject [

	claimMinIdleMilliseconds := anObject
]

{ #category : 'private' }
RsStreamConsumerGroupPoller >> claimPending [
	self consumer autoClaimIdleMoreThan: self claimMinIdleMilliseconds.
	self updateLastClaimTimestamp
]

{ #category : 'handling' }
RsStreamConsumerGroupPoller >> handleReceived: receivedEntry [
	super handleReceived: receivedEntry.
	receivedEntry accept
]

{ #category : 'accessing' }
RsStreamConsumerGroupPoller >> lastClaimTimestamp [
	^ lastClaimTimestamp
]

{ #category : 'private' }
RsStreamConsumerGroupPoller >> pollNeverDelivered [
	^ self consumer
		  neverDeliveredAtMost: self readChunkSize
		  waitFor: self waitMilliseconds
]

{ #category : 'private' }
RsStreamConsumerGroupPoller >> pollPending [
	| minMessageId |
	minMessageId := RsStreamMessageId zero.
	^ self consumer pendingsAtMost: self readChunkSize after: minMessageId
	
]

{ #category : 'testing' }
RsStreamConsumerGroupPoller >> shouldAutoClaim [
	shouldAutoClaimBlock ifNil: [ ^false ].
	^ self shouldAutoClaimBlock value: self
]

{ #category : 'claiming' }
RsStreamConsumerGroupPoller >> shouldAutoClaim: aBoolean [
	aBoolean
		ifTrue: [ self autoClaimIfTrue: [ :c | true ] ]
		ifFalse: [ self shouldAutoClaimBlock: nil ]
]

{ #category : 'accessing' }
RsStreamConsumerGroupPoller >> shouldAutoClaimBlock [

	^ shouldAutoClaimBlock
]

{ #category : 'accessing' }
RsStreamConsumerGroupPoller >> shouldAutoClaimBlock: anObject [

	shouldAutoClaimBlock := anObject
]

{ #category : 'private' }
RsStreamConsumerGroupPoller >> updateLastClaimTimestamp [
	lastClaimTimestamp := DateAndTime now
]
