actions
unsubscribeAllAndStop
	[ self isRunning ifFalse: [ ^ self ].
	self stop.
	self unsubscribeAll.
	2 seconds wait.
	self releaseSubscriber ]
		on: Error
		do: [ :ex | self logger error: ex ]