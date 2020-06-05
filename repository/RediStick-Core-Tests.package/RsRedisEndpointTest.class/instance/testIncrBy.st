test
testIncrBy
	stick endpoint set: 'keyA' value: 10.
	stick endpoint incr: 'keyA' by: 5.
	self assert: (stick endpoint get: 'keyA') equals: 15 asString