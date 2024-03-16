*RediStick-Stream
xLen: key

	^ self unifiedCommand: { 'XLEN'. key }