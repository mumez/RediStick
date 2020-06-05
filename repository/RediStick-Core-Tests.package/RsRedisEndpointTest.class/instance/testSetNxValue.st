test
testSetNxValue
	self endpoint set: 'keyA' value: 10.
	self endpoint setNx: 'keyA' value: 20.
	self assert: (self endpoint get: 'keyA') equals: 10 asString.
	self endpoint setNx: 'keyB' value: 20.
	self assert: (self endpoint get: 'keyB') equals: 20 asString