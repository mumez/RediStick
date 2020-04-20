commands-pubsub
punsubscribe: channelPatterns
	self unifiedCommand: {'PUNSUBSCRIBE'} , channelPatterns.
	channels ifNil: [ ^self ].
	channels := channels copyWithoutAll: channelPatterns.
	channels ifEmpty: [subscriptionMode := nil]