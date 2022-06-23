running
tearDown
	connectionPool releaseConnections.
	subscriptionManager unsubscribeChannels.
	
	super tearDown.