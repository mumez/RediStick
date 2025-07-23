Class {
	#name : 'RsRedisPingChannel',
	#superclass : 'RsRedisPubsubChannel',
	#instVars : [
		'sentToken'
	],
	#category : 'RediStick-Pubsub',
	#package : 'RediStick-Pubsub'
}

{ #category : 'constants' }
RsRedisPingChannel class >> channelName [
	^ 'PING-', RsRedisPubsubChannel pingChannelId
]

{ #category : 'event-handling' }
RsRedisPingChannel >> handlePublished: payload [
	| replyReceived |
	replyReceived := (sentToken = payload).
	replyReceived ifFalse: [ 
		self resetSubscriptions
	]
	
	
]

{ #category : 'actions' }
RsRedisPingChannel >> publishPing [
	self tokenExpired ifTrue: [ 
		self resetSubscriptions
	].
	sentToken := self secondsFromUnixEpoch.
	self publish: sentToken
	
]

{ #category : 'private' }
RsRedisPingChannel >> resetSubscriptions [

	[ RsRedisSubscriptionManager reset ]
		on: Error
		do: [ :ex | RsRedisSubscriptionManager logger error: ex ]
]

{ #category : 'private' }
RsRedisPingChannel >> secondsFromUnixEpoch [
	^ (DateAndTime now asUTC - DateAndTime unixEpoch) asSeconds
]

{ #category : 'testing' }
RsRedisPingChannel >> shouldBeSubscribed [
	^ true
]

{ #category : 'private' }
RsRedisPingChannel >> tokenExpired [
	sentToken ifNil: [ ^false ].
	^ (self secondsFromUnixEpoch - sentToken) > (RsRedisSubscriptionManager default intervalSeconds * 1.1) ceiling
]
