*RediStick-Stream
xRead: key id: id count: count
	^ self xRead: key id: id using: [ :opts | opts count: count ] 