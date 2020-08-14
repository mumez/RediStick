tests
testHSet
	self endpoint hSet: 'keyA' field: 'god'  value: 'zeus'.
	self assert: (self endpoint hGetAll: 'keyA') equals:  (Dictionary with: ('god' -> 'zeus'))