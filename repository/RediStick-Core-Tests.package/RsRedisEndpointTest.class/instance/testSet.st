tests
testSet
	stick endpoint set: 'key' value: 'valueB'.
	self assert: (stick endpoint get: 'key') equals: 'valueB'