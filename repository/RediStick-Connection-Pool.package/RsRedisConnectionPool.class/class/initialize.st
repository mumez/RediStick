class initialization
initialize
	default := nil.
	logger := nil.
	
	maxRedisConnectionsPerKey := nil.
	primaryUrl := secondaryUrl := nil.
	
	Smalltalk addToStartUpList: self.