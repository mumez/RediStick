accessing
connectionPool: aRedis
	connectionPool ifNil: [ connectionPool := RsRedisConnectionPool default ]