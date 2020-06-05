test
testDecrBy
	stick endpoint set: 'keyA' value: 10.
	self assert: (stick endpoint get: 'keyA') equals: 10 asString.
	stick endpoint decr: 'keyA' by: 5.
	self assert: (stick endpoint get: 'keyA') equals: 5 asString