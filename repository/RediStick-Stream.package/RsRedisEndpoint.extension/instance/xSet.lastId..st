*RediStick-Stream
xSet: key lastId: lastId

	^ self unifiedCommand: {
			  'XSETID'.
			  key.
			  lastId asString }