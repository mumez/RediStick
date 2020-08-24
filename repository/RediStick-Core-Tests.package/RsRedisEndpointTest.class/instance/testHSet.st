tests
testHSet
	stick endpoint hSet: 'keyA' field: 'god'  value: 'zeus'.
	self assert: (stick endpoint hGetAll: 'keyA') equals:  (Dictionary with: ('god' -> 'zeus'))