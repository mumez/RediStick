test
testFlushDb
	self endpoint set: 'keyA' value: 'valueA'.
	self assert: (self endpoint get: 'keyA') equals: 'valueA'.
	self endpoint flushDb.
	self assert: (self endpoint get: 'keyA') equals: nil