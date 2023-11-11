*RediStick-Stream
xRange: key start: startId end: endId count: count
	^ self xRange: 'XRANGE' key: key start: startId end: endId count: count