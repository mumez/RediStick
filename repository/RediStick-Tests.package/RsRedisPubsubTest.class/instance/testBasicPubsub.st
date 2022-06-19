tests
testBasicPubsub
	| mockPubsub originalPayload |
	3 seconds wait.
	mockPubsub := RsRedisPubsubChannel named: #mockPubsub.
	mockPubsub connectionPool: connectionPool. "Explicitly set connectionPool for testing"
	originalPayload := #('aaa' 'bbb').
	mockPubsub publish: originalPayload.
	100 milliSeconds wait.
	
	self assert: (originalPayload = mockPubsub payloadReceived)