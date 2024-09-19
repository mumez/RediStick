*RediStick-Stream
xRange: key nextFrom: startId count: count
	^ self xRange: key start: ('(', startId asString) end: '+' count: count