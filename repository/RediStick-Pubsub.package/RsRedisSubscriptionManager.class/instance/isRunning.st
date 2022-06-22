starting/stopping
isRunning
	connectionKeeper ifNil: [ ^ false ].
	^ (connectionKeeper isTerminating or: [ 
		   connectionKeeper isTerminated or: [ connectionKeeper isSuspended ] ])
		  not