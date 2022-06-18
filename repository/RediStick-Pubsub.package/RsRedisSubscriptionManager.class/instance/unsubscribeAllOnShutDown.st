startup - shutdown
unsubscribeAllOnShutDown
	[ self isRunning ifFalse: [ ^ self ].
	self stop.
	self unsubscribeAll ]
		on: Error
		do: [ :ex | self logger error: ex ]