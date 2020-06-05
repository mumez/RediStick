test
testSetNxValue
	stick endpoint set: 'keyA' value: 10.
	stick endpoint setNx: 'keyA' value: 20.
	self assert: (stick endpoint get: 'keyA') equals: 10 asString.
	stick endpoint setNx: 'keyB' value: 20.
	self assert: (stick endpoint get: 'keyB') equals: 20 asString