class initialization
initialize
	self initDefault.
	
	logger := nil.
	subscribeChannelsOnStartup := true.
	
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self