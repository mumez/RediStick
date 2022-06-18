starting/stopping
isRunning
	connectionKeeper ifNil: [ ^false ].
	^ self connectionKeeper isRunning