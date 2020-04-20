commands-pubsub
unsubscribe
	self inlineCommand: 'UNSUBSCRIBE'.
	channels := nil.
	subscriptionMode := nil