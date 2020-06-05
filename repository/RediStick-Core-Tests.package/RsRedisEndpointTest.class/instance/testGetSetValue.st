test
testGetSetValue
	stick endpoint set: 'keyA' value: 'hello'.
	self assert: (stick endpoint get: 'keyA') equals: 'hello'.
	self
		assert: (stick endpoint getSet: 'keyA' value: 'midgard')
		equals: 'hello'.
	self assert: (stick endpoint get: 'keyA') equals: 'midgard'