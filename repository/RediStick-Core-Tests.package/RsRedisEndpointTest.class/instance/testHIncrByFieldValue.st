test
testHIncrByFieldValue
	self endpoint hSet: 'keyA' field: 'counter' value: 0.
	self
		assert: (self endpoint hGet: 'keyA' field: 'counter')
		equals: 0 asString.
	self endpoint hIncrBy: 'keyA' field: 'counter' value: 10.
	self
		assert: (self endpoint hGet: 'keyA' field: 'counter')
		equals: 10 asString