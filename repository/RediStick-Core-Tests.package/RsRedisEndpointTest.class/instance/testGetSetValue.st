test
testGetSetValue
	self endpoint set: 'keyA' value: 'hello'.
	self assert: (self endpoint get: 'keyA') equals: 'hello'.
	self
		assert: (self endpoint getSet: 'keyA' value: 'midgard')
		equals: 'hello'.
	self assert: (self endpoint get: 'keyA') equals: 'midgard'