*RediStick-Stream
xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer blocking: milliseconds
	^ self xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: [:opts | opts blocking: milliseconds ].