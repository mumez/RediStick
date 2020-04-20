commands-pubsub
subscribe: channelArray callback: aBlock 
	pubsub
		ifTrue: [(SkError kind: #pubsub) signal: 'Already in pubsub mode. Unsubscribe first.']
		ifFalse: [self enterPubsub.
			self subscribe: channelArray].
	self spawnReceiveProcess: aBlock