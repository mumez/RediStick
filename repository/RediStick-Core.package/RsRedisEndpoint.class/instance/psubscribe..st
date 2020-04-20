commands-pubsub
psubscribe: channelPatterns
	pubsub
		ifTrue: [ self unifiedCommand: {'PSUBSCRIBE'} , channelPatterns ]
		ifFalse: [ (SkError kind: #pubsub) signal: 'Not in pubsub mode, pass a callback block first.' ].
	channels := channelPatterns.
	subscriptionMode := #patterns.