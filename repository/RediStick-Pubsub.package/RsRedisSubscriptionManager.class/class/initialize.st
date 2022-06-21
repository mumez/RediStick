class initialization
initialize
	default ifNotNil: [ 
		default unsubscribeAllOnShutDown.
		default releaseSubscriber.
	].
	default := nil.
	
	logger := nil