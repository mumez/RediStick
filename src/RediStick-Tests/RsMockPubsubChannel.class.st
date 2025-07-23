Class {
	#name : 'RsMockPubsubChannel',
	#superclass : 'RsRedisPubsubChannel',
	#instVars : [
		'payloadReceived'
	],
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'constants' }
RsMockPubsubChannel class >> channelName [
	^#mockPubsub
]

{ #category : 'event-handling' }
RsMockPubsubChannel >> handlePublished: payload [
	
	payloadReceived := payload
]

{ #category : 'accessing' }
RsMockPubsubChannel >> payloadReceived [
	^ payloadReceived
]

{ #category : 'accessing' }
RsMockPubsubChannel >> payloadReceived: anObject [
	payloadReceived := anObject
]
