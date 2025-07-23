Class {
	#name : 'RsStreamConsumer',
	#superclass : 'Object',
	#instVars : [
		'name',
		'group',
		'stream'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'instance creation' }
RsStreamConsumer class >> named: consumerName [
	^ self new name: consumerName; yourself
]

{ #category : 'instance creation' }
RsStreamConsumer class >> named: consumerName groupNamed: aStreamConsumerGroupName streamNamed: aStreamName [
	^ (self named: consumerName) initGroupName: aStreamConsumerGroupName streamName: aStreamName
]

{ #category : 'instance creation' }
RsStreamConsumer class >> named: consumerName on: aStreamConsumerGroup [
	^ self named: consumerName groupNamed: aStreamConsumerGroup name streamNamed: aStreamConsumerGroup streamName
]

{ #category : 'reading' }
RsStreamConsumer >> accept: aStreamEntry [
	^ self group accept: aStreamEntry
]

{ #category : 'reading' }
RsStreamConsumer >> allPendings [
	^ self pendingsAfter: RsStreamMessageId zero
]

{ #category : 'actions' }
RsStreamConsumer >> assureExistence [
	self endpoint xGroupCreateConsumer: self streamName group: self groupName consumer: self name
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimFrom: start idleMoreThan: milliseconds [
	^ self autoClaimFrom: start idleMoreThan: milliseconds atMost: self settings claimReadChunkSize 
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimFrom: start idleMoreThan: milliseconds atMost: count [
	^ self group autoClaimFrom: start idleMoreThan: milliseconds atMost: count on: self name
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimIdleMoreThan: milliseconds [
	^ self autoClaimFrom: RsStreamMessageId zero idleMoreThan: milliseconds
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimIdling [
	^ self autoClaimIdsIdleMoreThan: self settings claimMinIdleMilliseconds
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimIdsFrom: start idleMoreThan: milliseconds [
	^ self autoClaimIdsFrom: start idleMoreThan: milliseconds atMost: self settings claimReadChunkSize 
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimIdsFrom: start idleMoreThan: milliseconds atMost: count [
	^ self group autoClaimIdsFrom: start idleMoreThan: milliseconds atMost: count on: self name
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimIdsIdleMoreThan: milliseconds [
	^ self autoClaimIdsFrom: RsStreamMessageId zero idleMoreThan: milliseconds
]

{ #category : 'claiming' }
RsStreamConsumer >> autoClaimIdsIdling [
	^ self autoClaimIdsIdleMoreThan: self settings claimMinIdleMilliseconds
]

{ #category : 'actions' }
RsStreamConsumer >> delete [
	^ self endpoint xGroupDelConsumer: self streamName group: self groupName consumer: self name
]

{ #category : 'accessing' }
RsStreamConsumer >> endpoint [
	^ self stream endpoint
]

{ #category : 'accessing' }
RsStreamConsumer >> group [
	^ group
]

{ #category : 'factory' }
RsStreamConsumer >> groupClass [
	^ RsStreamConsumerGroup 
]

{ #category : 'accessing' }
RsStreamConsumer >> groupName [
	^ self group name
]

{ #category : 'initialization' }
RsStreamConsumer >> initGroup: aStreamConsumerGroup [
	group := aStreamConsumerGroup.
	stream := aStreamConsumerGroup stream.
]

{ #category : 'initialization' }
RsStreamConsumer >> initGroupName: aStreamConsumerGroupName streamName: aStreamName [
	self initGroup: (self groupClass named: aStreamConsumerGroupName streamNamed: aStreamName)
]

{ #category : 'accessing' }
RsStreamConsumer >> name [

	^ name
]

{ #category : 'accessing' }
RsStreamConsumer >> name: anObject [

	name := anObject
]

{ #category : 'reading' }
RsStreamConsumer >> neverDeliveredAtMost: count [
	^ self group neverDeliveredAtMost: count on: self name
]

{ #category : 'reading' }
RsStreamConsumer >> neverDeliveredAtMost: count waitFor: milliseconds [
	^ self group neverDeliveredAtMost: count waitFor: milliseconds on: self name
]

{ #category : 'reading' }
RsStreamConsumer >> neverDeliveredNoAckAtMost: count waitFor: milliseconds [
	^ self group neverDeliveredNoAckAtMost: count waitFor: milliseconds on: self name
]

{ #category : 'polling' }
RsStreamConsumer >> noAckPoller [
	^ self noAckPollerClass on: self
]

{ #category : 'factory' }
RsStreamConsumer >> noAckPollerClass [
	^ RsStreamConsumerGroupNoAckPoller
]

{ #category : 'accessing-pending-list' }
RsStreamConsumer >> pendingListAtMost: limit [
	^ self pendingListFrom: RsStreamMessageId min end: RsStreamMessageId max atMost: limit
]

{ #category : 'accessing-pending-list' }
RsStreamConsumer >> pendingListFrom: startId end: endId atMost: count [
	^ self endpoint xPending: self streamName group: self groupName start: startId end: endId count: count consumer: self name
]

{ #category : 'reading' }
RsStreamConsumer >> pendingsAfter: latestMessageId [
	^ self group pendingsAfter: latestMessageId on: self name
]

{ #category : 'reading' }
RsStreamConsumer >> pendingsAtMost: count after: latestMessageId [
	^ self group pendingsAtMost: count after: latestMessageId on: self name
]

{ #category : 'polling' }
RsStreamConsumer >> poller [
	^ self pollerClass on: self
]

{ #category : 'factory' }
RsStreamConsumer >> pollerClass [
	^ RsStreamConsumerGroupPoller
]

{ #category : 'copying' }
RsStreamConsumer >> sameNameAndGrouped [
	^ self class named: self name groupNamed: self groupName streamNamed: self stream name 
]

{ #category : 'accessing' }
RsStreamConsumer >> settings [
	^ self stream settings
]

{ #category : 'accessing' }
RsStreamConsumer >> stream [
	^ stream
]

{ #category : 'accessing' }
RsStreamConsumer >> stream: anObject [

	stream := anObject
]

{ #category : 'factory' }
RsStreamConsumer >> streamClass [
	^ RsStream
]

{ #category : 'accessing' }
RsStreamConsumer >> streamName [
	^ self stream name
]
