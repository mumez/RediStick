keeping-connection
stopPublishPing
	connectionKeeper ifNotNil: [ 
		connectionKeeper terminate.
		connectionKeeper := nil
	]