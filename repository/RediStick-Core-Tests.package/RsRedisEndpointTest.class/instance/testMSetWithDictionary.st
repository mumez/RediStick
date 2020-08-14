tests
testMSetWithDictionary
	| dict |
	dict := Dictionary with: 'keyA' -> 'valueA' with: 'keyB' -> 'valueB'.
	self endpoint mSet: dict.
	self assert: (self endpoint get: 'keyA') equals: 'valueA'.
	self assert: (self endpoint get: 'keyB') equals: 'valueB'