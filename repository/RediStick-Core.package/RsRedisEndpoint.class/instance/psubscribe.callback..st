commands-pubsub
psubscribe: channelPatterns callback: aBlock 
	pubsub
		ifTrue: [(RsError pubsub) signal: 'Already in pubsub mode. Unsubscribe first.']
		ifFalse: [self enterPubsub.
			self psubscribe: channelPatterns].
	self spawnReceiveProcess: aBlock