*RediStick-Stream
xRevRange: key from: startId count: count
	^ self xRevRange: key start: startId asString end: '-' count: count