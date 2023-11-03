commands-stream
xRevRange: key start: startId end: endId count: count
	^ self xRange: 'XREVRANGE' key: key start: startId end: endId count: count