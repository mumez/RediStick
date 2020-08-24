tests
testMSetWithDictionary
	| dict |
	dict := Dictionary with: 'keyA' -> 'valueA' with: 'keyB' -> 'valueB'.
	stick endpoint mSet: dict.
	self assert: (stick endpoint get: 'keyA') equals: 'valueA'.
	self assert: (stick endpoint get: 'keyB') equals: 'valueB'