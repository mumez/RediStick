class initialization
initialize
	self initDefault.
	
	logger := nil.
	subscribeAllOnStartup := true.
	
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self