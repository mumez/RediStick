test
testHGetField
	self endpoint hSet: 'keyA' field: 'fieldA' value: 'valueA'.
	self
		assert: (self endpoint hGet: 'keyA' field: 'fieldA')
		equals: 'valueA'.
	self
		assert: (self endpoint hGet: 'keyA' field: 'unknowField')
		equals: nil