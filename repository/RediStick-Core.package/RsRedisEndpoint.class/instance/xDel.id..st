commands-stream
xDel: key id: id

	^ self unifiedCommand: {
			  'XDEL'.
			  key.
			  id }