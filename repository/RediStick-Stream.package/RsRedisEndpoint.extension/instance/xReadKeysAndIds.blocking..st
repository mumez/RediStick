*RediStick-Stream
xReadKeysAndIds: keysAndIds blocking: milliseconds
	^ self xReadKeysAndIds: keysAndIds using: [:opts | opts blocking: milliseconds]