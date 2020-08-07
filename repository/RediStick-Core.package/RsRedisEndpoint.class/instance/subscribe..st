commands-pubsub
subscribe: channelArray
	pubsub
		ifTrue: [ self unifiedCommand: {'SUBSCRIBE'} , channelArray ]
		ifFalse: [ (RsError pubsub) signal: 'Not in pubsub mode, pass a callback block first.' ].
	channels := channelArray.
	subscriptionMode := #normal.