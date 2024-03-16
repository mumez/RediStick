*RediStick-Stream
xReadKeysAndIds: keysAndIds count: count
	^ self xReadKeysAndIds: keysAndIds using: [:opts | opts count: count]