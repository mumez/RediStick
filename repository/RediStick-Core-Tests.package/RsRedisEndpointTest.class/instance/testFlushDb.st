test
testFlushDb

	stick endpoint set: 'keyA' value: 'valueA'.
	self assert: (stick endpoint get: 'keyA') equals: 'valueA'.
	stick endpoint flushDb.
	self assert: (stick endpoint get: 'keyA') equals: nil   