test
testDecrBy
	self endpoint set: 'keyA' value: 10.
	self assert: (self endpoint get: 'keyA') equals: 10 asString.
	self endpoint decr: 'keyA' by: 5.
	self assert: (self endpoint get: 'keyA') equals: 5 asString