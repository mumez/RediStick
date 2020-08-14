tests
testSet
	self endpoint set: 'key' value: 'valueB'.
	self assert: (self endpoint get: 'key') equals: 'valueB'