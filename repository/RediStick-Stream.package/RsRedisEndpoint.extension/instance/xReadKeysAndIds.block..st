*RediStick-Stream
xReadKeysAndIds: keysAndIds block: milliseconds
	^ self xReadKeysAndIds: keysAndIds using: [:opts | opts block: milliseconds]