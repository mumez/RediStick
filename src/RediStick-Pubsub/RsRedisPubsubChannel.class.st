Class {
	#name : 'RsRedisPubsubChannel',
	#superclass : 'Object',
	#instVars : [
		'connectionPool',
		'shouldBeSubscribed'
	],
	#classInstVars : [
		'channelsDict',
		'pingChannelId'
	],
	#category : 'RediStick-Pubsub',
	#package : 'RediStick-Pubsub'
}

{ #category : 'constants' }
RsRedisPubsubChannel class >> channelName [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RsRedisPubsubChannel class >> channelNames [
	^self channelsDict keys collect: #asString
]

{ #category : 'accessing' }
RsRedisPubsubChannel class >> channelsDict [
	^ channelsDict
		ifNil: [ self initChannelsDict.
			channelsDict ]
]

{ #category : 'class initialization' }
RsRedisPubsubChannel class >> initChannelsDict [
	channelsDict := IdentityDictionary new.
	self allSubclassesDo: [ :each | channelsDict at: each channelName asSymbol put: each new ]
]

{ #category : 'class initialization' }
RsRedisPubsubChannel class >> initPingChannelId [
	pingChannelId := UUID new asString36
]

{ #category : 'class initialization' }
RsRedisPubsubChannel class >> initialize [
	self initPingChannelId.
	self initChannelsDict
]

{ #category : 'instance creation' }
RsRedisPubsubChannel class >> named: aSymbol [

	^ self channelsDict at: aSymbol asSymbol ifAbsentPut: [ 
		  | detected |
		  detected := self allSubclasses
			              detect: [ :each | each channelName = aSymbol ]
			              ifNone: [ ^ nil ].
		  detected new ]
]

{ #category : 'instance creation' }
RsRedisPubsubChannel class >> ping [
	^self named: (RsRedisPingChannel channelName)
]

{ #category : 'accessing' }
RsRedisPubsubChannel class >> pingChannelId [
	pingChannelId ifNil: [ self initPingChannelId ].
	^pingChannelId 
]

{ #category : 'accessing' }
RsRedisPubsubChannel class >> subscribingChannelNames [
	^ (self channelsDict values select: [ :each | 
		   each shouldBeSubscribed ]) collect: #channelName
]

{ #category : 'accessing' }
RsRedisPubsubChannel >> channelName [
	^self class channelName
]

{ #category : 'accessing' }
RsRedisPubsubChannel >> connectionPool [

	^ connectionPool ifNil: [ connectionPool := RsRedisConnectionPool default ]
]

{ #category : 'accessing' }
RsRedisPubsubChannel >> connectionPool: aRedis [
	connectionPool ifNil: [ connectionPool := RsRedisConnectionPool default ]
]

{ #category : 'event-handling' }
RsRedisPubsubChannel >> handlePublished: payload [
	"override"
]

{ #category : 'logging' }
RsRedisPubsubChannel >> logger [
	^self class logger
]

{ #category : 'publishing' }
RsRedisPubsubChannel >> publish: message [
	self publisherRedis publish: self channelName message: (STONJSON toString: message)
]

{ #category : 'accessing' }
RsRedisPubsubChannel >> publisherRedis [
	| redis |
	redis := RsRedisProxy pubsub.
	redis connectionPool: self connectionPool.
	^ redis
]

{ #category : 'event-handling' }
RsRedisPubsubChannel >> rawHandlePublished: payload [
	self handlePublished: (STONJSON fromString: payload)
]

{ #category : 'testing' }
RsRedisPubsubChannel >> shouldBeSubscribed [
	^ shouldBeSubscribed ifNil: [ shouldBeSubscribed := true ]
]

{ #category : 'testing' }
RsRedisPubsubChannel >> shouldBeSubscribed: aBoolean [
	shouldBeSubscribed := aBoolean
]
