factory
newRedisConnectionAt: key
	^ self redisWrapperClass on: (self createStickAt: key)