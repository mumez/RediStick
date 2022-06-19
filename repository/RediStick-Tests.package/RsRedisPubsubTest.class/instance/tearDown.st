running
tearDown
	connectionPool releaseConnections.
	subscriptionManager unsubscribeAll.
	
	super tearDown.