class initialization
initialize
	default ifNotNil: [ 
		default unsubscribeAllAndStop.
		default releaseSubscriber.
	].
	default := nil.
	
	logger := nil