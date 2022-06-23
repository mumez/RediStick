tests
testBasicPubsub
	| mockPubsub originalPayload |
	mockPubsub := RsRedisPubsubChannel named: #mockPubsub.
	mockPubsub connectionPool: connectionPool. "Explicitly set connectionPool for testing"
	subscriptionManager subscribeChannels.
	2 seconds wait.
	
	originalPayload := #('aaa' 'bbb').
	mockPubsub publish: originalPayload.
	100 milliSeconds wait.
	
	self assert: (originalPayload = mockPubsub payloadReceived)