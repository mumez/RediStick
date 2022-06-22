actions
unsubscribeAllAndStop
	[ self isRunning ifFalse: [ ^ self ].
	self stop.
	self unsubscribeAll.
	self releaseSubscriber ]
		on: Error
		do: [ :ex | self logger error: ex ]