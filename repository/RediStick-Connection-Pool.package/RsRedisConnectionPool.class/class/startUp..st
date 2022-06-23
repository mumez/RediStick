system startup
startUp: resuming
	resuming ifFalse: [ ^ self ].
	default ifNotNil: [ default cleanConnections ]