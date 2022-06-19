accessing
publisherRedis
	| redis |
	redis := RsRedisProxy pubsub.
	redis connectionPool: self connectionPool.
	^ redis