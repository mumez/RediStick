test
testHExistsField
	self endpoint hSet: 'keyA' field: 'fieldA' value: 'valueA'.
	self deny: (self endpoint hExists: 'keyA' field: 'unknowField').
	self assert: (self endpoint hExists: 'keyA' field: 'fieldA')