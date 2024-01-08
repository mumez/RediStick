*RediStick-Stream
xPending: key group: group
	^ self unifiedCommand: {
			  'XPENDING'.
			  key.
			  group }