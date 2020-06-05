test
testIncrBy
	self endpoint set: 'keyA' value: 10.
	self endpoint incr: 'keyA' by: 5.
	self assert: (self endpoint get: 'keyA') equals: 15 asString