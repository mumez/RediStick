*RediStick-Stream
xDel: key ids: ids

	^ self unifiedCommand: {
			  'XDEL'.
			  key.
			  }, ids asArray