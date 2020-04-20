commands-pubsub
publish: channel message: message
	^ self
		unifiedCommand:
			{'PUBLISH'.
			channel.
			message}