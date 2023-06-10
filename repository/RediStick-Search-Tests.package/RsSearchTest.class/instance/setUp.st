running
setUp
	super setUp.
	stick onRedisGenericError: [:ex| ex pass].