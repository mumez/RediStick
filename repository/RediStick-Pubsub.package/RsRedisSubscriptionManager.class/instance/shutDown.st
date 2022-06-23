actions
shutDown
	[ self isRunning ifFalse: [ ^ self ].
	self stop.
	self unsubscribeChannels.
	2 seconds wait.
	self releaseSubscriber ]
		on: Error
		do: [ :ex | self logger error: ex ]