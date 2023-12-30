*RediStick-Stream
xRead: key id: id blocking: milliseconds
	^ self xRead: key id: id using: [ :opts | opts blocking: milliseconds ] 