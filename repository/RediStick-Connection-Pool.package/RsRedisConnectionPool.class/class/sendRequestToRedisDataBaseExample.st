examples
sendRequestToRedisDataBaseExample
	<example>
	| rsPool |
	rsPool := RsRedisConnectionPool default.
	rsPool
		connectionDo:
				[ :rsRedisWrapper | rsRedisWrapper endpoint set: 'redisKeyA' value: 10 ]
			at: 'YourKey';
		connectionDo: [ :rsRedisWrapper | rsRedisWrapper endpoint get: 'redisKeyA' ]
			at: 'YourKey'.
	rsPool inspect