actions
sizeOfListAt: key
	^ (self endpoint lLen: key) ifNil: [ 0 ]