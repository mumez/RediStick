test
testHSetFieldValue
	self endpoint hSet: 'keyA' field: 'fieldA' value: 'valueA'.
	self
		assert: (self endpoint hGet: 'keyA' field: 'fieldA')
		equals: 'valueA'