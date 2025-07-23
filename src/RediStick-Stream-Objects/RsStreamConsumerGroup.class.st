Class {
	#name : 'RsStreamConsumerGroup',
	#superclass : 'Object',
	#instVars : [
		'name',
		'fromId',
		'currentId',
		'autoCreateStream',
		'stream'
	],
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'instance creation' }
RsStreamConsumerGroup class >> named: groupName [
	^ self new name: groupName; yourself
]

{ #category : 'instance creation' }
RsStreamConsumerGroup class >> named: groupName on: aStream [
	^ self named: groupName on: aStream from: nil
]

{ #category : 'instance creation' }
RsStreamConsumerGroup class >> named: groupName on: aStream from: fromId [
	^ (self named: groupName) on: aStream from: fromId
]

{ #category : 'instance creation' }
RsStreamConsumerGroup class >> named: groupName streamNamed: streamName [
	^ self named: groupName streamNamed: streamName from: nil
]

{ #category : 'instance creation' }
RsStreamConsumerGroup class >> named: groupName streamNamed: streamName from: fromId [
	^ (self named: groupName) initStreamName: streamName from: fromId
]

{ #category : 'reading' }
RsStreamConsumerGroup >> accept: aStreamEntry [
	| msgId |
	msgId := aStreamEntry asStreamMessageId. 
	self endpoint xAck: self streamName group: self name id: msgId.
	currentId := msgId
]

{ #category : 'actions' }
RsStreamConsumerGroup >> assureExistence [
	[self endpoint xGroupCreate: self streamName group: self name id: self fromId createNotExists: true] on: Error do: [ :ex | ex inspect ]
]

{ #category : 'claiming' }
RsStreamConsumerGroup >> autoClaimFrom: start idleMoreThan: milliseconds atMost: count on: consumerName [
	^ self endpoint xAutoClaim: self streamName group: self name consumer: consumerName minIdleTime: milliseconds start: start count: count
]

{ #category : 'claiming' }
RsStreamConsumerGroup >> autoClaimIdsFrom: start idleMoreThan: milliseconds atMost: count on: consumerName [
	^ self endpoint xAutoClaim: self streamName group: self name consumer: consumerName minIdleTime: milliseconds start: start count: count idsOnly: true
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> autoCreateStream [

	^ autoCreateStream ifNil: [ autoCreateStream := false ]
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> autoCreateStream: anObject [

	autoCreateStream := anObject
]

{ #category : 'actions' }
RsStreamConsumerGroup >> changeLastDeliveredMessageId: aStreamMessageId [
	self changeLastDeliveredMessageId: aStreamMessageId entriesRead: nil
]

{ #category : 'actions' }
RsStreamConsumerGroup >> changeLastDeliveredMessageId: aStreamMessageId entriesRead: entriesRead [
	| newMessageId |
	newMessageId := aStreamMessageId asStreamMessageId.
	self endpoint xGroupSetId: self name group: self name id: newMessageId entriesRead: entriesRead.
	self initMessageId: newMessageId
]

{ #category : 'factory' }
RsStreamConsumerGroup >> consumerClass [
	^ RsStreamConsumer
]

{ #category : 'consumers' }
RsStreamConsumerGroup >> consumerNamed: consumerName [
	^ (self consumerClass named: consumerName on: self) assureExistence
]

{ #category : 'consumers' }
RsStreamConsumerGroup >> consumersInfo [
	| consumersInfo |
	consumersInfo :=  self endpoint xInfoConsumers: self streamName group: self name.
	^ consumersInfo inject: Dictionary new into: [ :sum :each | sum at: each name put: each; yourself ]
]

{ #category : 'defaults' }
RsStreamConsumerGroup >> defaultAcceptor [
	^ [ :entry | self accept: entry]
]

{ #category : 'actions' }
RsStreamConsumerGroup >> destroy [
	^ (self endpoint xGroupDestroy: self streamName group: self name) = 1
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> endpoint [
	^ self stream endpoint
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> fromFirst [
	self initMessageId: RsStreamMessageId zero
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> fromId [

	^ fromId ifNil: [ fromId := RsStreamMessageId zero ]
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> fromId: idLikeThing [
	self initMessageId: idLikeThing
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> fromLast [
	self initMessageId: RsStreamMessageId newest 
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> fromNeverDelivered [
	self initMessageId: RsStreamMessageId neverDelivered
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> initMessageId: idLikeThing [
	fromId := idLikeThing asStreamMessageId.
	currentId := idLikeThing asStreamMessageId.
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> initStreamName: aString from: fromMessageId [
	self on: (self streamClass named: aString) from: fromMessageId
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> name [

	^ name
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> name: anObject [

	name := anObject
]

{ #category : 'reading' }
RsStreamConsumerGroup >> neverDeliveredAtMost: count on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id:  RsStreamMessageId neverDelivered
		  group: self name
		  consumer: consumerName
		  count: count)
]

{ #category : 'reading' }
RsStreamConsumerGroup >> neverDeliveredAtMost: count waitFor: milliseconds on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id:  RsStreamMessageId neverDelivered
		  group: self name
		  consumer: consumerName
		  blocking: milliseconds
		  count: count)
]

{ #category : 'reading' }
RsStreamConsumerGroup >> neverDeliveredNoAckAtMost: count waitFor: milliseconds on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
			   xGroupRead: self streamName
			   id: RsStreamMessageId neverDelivered
			   group: self name
			   consumer: consumerName
			   using: [ :opts |
				   opts
					   noAck: true;
					   blocking: milliseconds;
					   count: count ])
]

{ #category : 'initialization' }
RsStreamConsumerGroup >> on: aStream from: idLikeThing [
	stream := aStream.
	idLikeThing ifNil: [ ^ self fromFirst ].
	self initMessageId: idLikeThing
]

{ #category : 'accessing-pending-list' }
RsStreamConsumerGroup >> pendingListFrom: startId end: endId limit: count [
	^ self endpoint xPending: self streamName group: self name start: startId end: endId count: count
]

{ #category : 'accessing-pending-list' }
RsStreamConsumerGroup >> pendingListIdleMoreThan: milliseconds limit: count [
	^ self endpoint xPending: self streamName group: self name start: RsStreamMessageId min end: RsStreamMessageId max count: count minIdleMilliseconds: milliseconds
]

{ #category : 'reading' }
RsStreamConsumerGroup >> pendingsAfter: latestMessageId on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName)
]

{ #category : 'reading' }
RsStreamConsumerGroup >> pendingsAtMost: count after: latestMessageId on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName
		  count: count)
]

{ #category : 'reading' }
RsStreamConsumerGroup >> pendingsNoAckAfter: latestMessageId on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName
		  using: [ :opts | opts noAck ])
]

{ #category : 'reading' }
RsStreamConsumerGroup >> pendingsNoAckAtMost: count after: latestMessageId on: consumerName [
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName
		  using: [ :opts |
			  opts
				  noAck;
				  count: count ])
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> settings [
	^ self stream settings
]

{ #category : 'actions' }
RsStreamConsumerGroup >> setup: entriesRead [
	self endpoint xGroupCreate: self streamName group: self name id: self fromId createNotExists: self autoCreateStream entriesRead: entriesRead
]

{ #category : 'actions' }
RsStreamConsumerGroup >> setupEmpty [
	self autoCreateStream: true.
	self fromFirst.
	self setup: nil
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> stream [
	^ stream
]

{ #category : 'factory' }
RsStreamConsumerGroup >> streamClass [
	^ RsStream
]

{ #category : 'accessing' }
RsStreamConsumerGroup >> streamName [

	^ self stream name
]

{ #category : 'accessing-pending-list' }
RsStreamConsumerGroup >> summaryPendingList [
	^ self endpoint xPending: self streamName group: self name
]

{ #category : 'private' }
RsStreamConsumerGroup >> wrapAsAcceptableEntries: streamEntries [
	streamEntries do: [ :each | each acceptor: self defaultAcceptor ].
	^ streamEntries
]
