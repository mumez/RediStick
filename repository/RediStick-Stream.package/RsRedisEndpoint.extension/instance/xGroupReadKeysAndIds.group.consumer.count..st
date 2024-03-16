*RediStick-Stream
xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer count: count
	^ self xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: [:opts | opts count: count ].