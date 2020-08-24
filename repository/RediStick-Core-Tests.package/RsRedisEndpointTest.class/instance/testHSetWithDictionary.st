tests
testHSetWithDictionary
	| dict |
	dict := Dictionary
		with: 'god' -> 'Cronos'
		with: 'location' -> 'tartarus'.
	stick endpoint hMSet: 'keyA' dictionary: dict.
	self assert: (stick endpoint hGetAll: 'keyA') equals: dict.
	self
		assert: (stick endpoint hGet: 'keyA' field: 'location')
		equals: (dict at: 'location')