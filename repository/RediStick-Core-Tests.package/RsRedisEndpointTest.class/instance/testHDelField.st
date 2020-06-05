test
testHDelField
	self endpoint hSet: 'keyA' field: 'fieldA' value: 'valueA'.
	self
		assert: (self endpoint hGet: 'keyA' field: 'fieldA')
		equals: 'valueA'.
	self endpoint hDel: 'keyA' field: 'fieldA'.
	self
		assert: (self endpoint hGet: 'keyA' field: 'fieldA')
		equals: nil