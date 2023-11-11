*RediStick-Stream
xRevRange: key nextFrom: startId count: count
	^ self xRevRange: key start: ('(', startId) end: '+' count: count