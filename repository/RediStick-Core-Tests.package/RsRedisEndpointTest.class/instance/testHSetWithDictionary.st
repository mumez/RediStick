tests
testHSetWithDictionary
	| dict |
	dict := Dictionary
		with: 'god' -> 'Cronos'
		with: 'location' -> 'tartarus'.
	self endpoint hMSet: 'keyA' dictionary: dict.
	self assert: (self endpoint hGetAll: 'keyA') equals: dict.
	self
		assert: (self endpoint hGet: 'keyA' field: 'location')
		equals: (dict at: 'location')