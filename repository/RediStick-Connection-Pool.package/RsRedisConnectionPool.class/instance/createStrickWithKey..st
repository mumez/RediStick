API
createStrickWithKey: aKey
	"return a redisWrapper see his class for more information"
	^ self newRedisConnectionAt: aKey