class initialization
initialize
	default ifNotNil: [ default unsubscribeAllOnShutDown ].
	default := nil.
	
	logger := nil