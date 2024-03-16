*RediStick-Stream
xDel: key id: id

	^ self unifiedCommand: {
			  'XDEL'.
			  key.
			  id }