*RediStick-Stream
xRead: key id: id blocking: milliseconds count: count
	^ self xRead: key id: id using: [ :opts | opts blocking: milliseconds; count: count ] 