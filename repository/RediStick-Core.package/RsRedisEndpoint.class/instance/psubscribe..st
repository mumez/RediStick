commands-pubsub
psubscribe: channelPatterns
	pubsub
		ifTrue: [ self unifiedCommand: {'PSUBSCRIBE'} , channelPatterns ]
		ifFalse: [ (RsError pubsub) signal: 'Not in pubsub mode, pass a callback block first.' ].
	channels := channelPatterns.
	subscriptionMode := #patterns.