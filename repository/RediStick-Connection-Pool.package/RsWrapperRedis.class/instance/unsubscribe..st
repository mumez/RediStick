pubsub
unsubscribe: channelArray
	^self endpoint unsubscribe: (channelArray collect: #asString)