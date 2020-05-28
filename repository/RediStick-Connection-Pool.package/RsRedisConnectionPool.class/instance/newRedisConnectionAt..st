factory
newRedisConnectionAt: aKey
	| redisWrapper |
	redisWrapper := self redisWrapperClass on: (self createStickAt: aKey).
	connections
		at: aKey
		ifPresent: [ RSStickWithSameNameAlreadyExistsException signal ]
		ifAbsentPut: redisWrapper.
	^ redisWrapper