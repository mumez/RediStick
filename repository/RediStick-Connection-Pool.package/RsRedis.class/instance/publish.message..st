pubsub
publish: channel message: message
	^self endpoint publish: channel asString message: message