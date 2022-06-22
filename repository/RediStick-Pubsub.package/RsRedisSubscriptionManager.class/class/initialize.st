class initialization
initialize
	default ifNotNil: [ 
		default unsubscribeAllAndStop.
	].
	default := nil.
	
	logger := nil.
	subscribeAllOnStartup := true.
	
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self