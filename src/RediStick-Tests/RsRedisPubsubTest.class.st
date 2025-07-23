Class {
	#name : 'RsRedisPubsubTest',
	#superclass : 'TestCase',
	#instVars : [
		'connectionPool',
		'subscriptionManager'
	],
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'running' }
RsRedisPubsubTest >> setUp [
	super setUp.
	
	connectionPool := RsRedisConnectionPool new. "For testing, do not user #default"
	connectionPool primaryUrl: RsRedisTestCase urlString.
	
	subscriptionManager := RsRedisSubscriptionManager new.
	subscriptionManager targetUrl: RsRedisTestCase urlString.
]

{ #category : 'running' }
RsRedisPubsubTest >> tearDown [
	connectionPool releaseConnections.
	subscriptionManager shutDown.
	
	super tearDown.
]

{ #category : 'tests' }
RsRedisPubsubTest >> testBasicPubsub [
	| mockPubsub originalPayload |
	mockPubsub := RsRedisPubsubChannel named: #mockPubsub.
	mockPubsub connectionPool: connectionPool. "Explicitly set connectionPool for testing"
	subscriptionManager subscribeChannels.
	2 seconds wait.
	
	originalPayload := #('aaa' 'bbb').
	mockPubsub publish: originalPayload.
	100 milliSeconds wait.
	
	self assert: (originalPayload = mockPubsub payloadReceived)
]
