running
setUp
	super setUp.
	
	redis := RsRedisProxy of: #test.
	connectionPool := RsRedisConnectionPool new. "For testing, do not user #default"
	connectionPool primaryUrl: RsRedisTestCase urlString.
	redis connectionPool: connectionPool.