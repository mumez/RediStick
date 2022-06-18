tests
testBasicPubsub
	| mockPubsub originalPayload |
	RsRedisSubscriptionManager unsubscribeAllOnShutDown.
	RsRedisSubscriptionManager subscribeAllOnStartUp.
	
	3 seconds wait.
	
	mockPubsub := RsRedisPubsubChannel named: #mockPubsub.
	originalPayload := #('aaa' 'bbb').
	mockPubsub publish: originalPayload.
	100 milliSeconds wait.
	
	self assert: (originalPayload = mockPubsub payloadReceived)