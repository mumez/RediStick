running
tearDown
	connectionPool releaseConnections.
	subscriptionManager shutDown.
	
	super tearDown.