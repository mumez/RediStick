examples
sendRequestToRedisDataBaseExample
	<example>
	| rsPool |
	rsPool := RsRedisConnectionPool default.
	rsPool
		connectionDo:
				[ :rsRedis | rsRedis endpoint set: 'redisKeyA' value: 10 ]
			at: 'YourKey';
		connectionDo: [ :rsRedis | rsRedis endpoint get: 'redisKeyA' ]
			at: 'YourKey'.
	rsPool inspect