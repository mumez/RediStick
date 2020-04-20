commands-pubsub
unsubscribe: channelArray
	self unifiedCommand: {'UNSUBSCRIBE'} , channelArray.
	channels ifNil: [ ^self ].
	channels := channels copyWithoutAll: channelArray.
	channels ifEmpty: [subscriptionMode := nil]