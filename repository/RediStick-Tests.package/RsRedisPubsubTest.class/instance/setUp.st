running
setUp
	super setUp.
	
	connectionPool := RsRedisConnectionPool new. "For testing, do not user #default"
	connectionPool primaryUrl: RsRedisTestCase urlString.
	
	subscriptionManager := RsRedisSubscriptionManager new.
	subscriptionManager targetUrl: RsRedisTestCase urlString.
	subscriptionManager subscribeChannels