accessing
connectionPool

	^ connectionPool ifNil: [ connectionPool := RsRedisConnectionPool default ]