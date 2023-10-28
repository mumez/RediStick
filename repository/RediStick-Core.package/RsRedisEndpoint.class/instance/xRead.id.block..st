commands-stream
xRead: key id: id block: milliseconds
	^ self xRead: key id: id using: [ :opts | opts block: milliseconds ] 