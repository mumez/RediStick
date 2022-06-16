tests
testHSetWithDictionary
	| dict |
	dict := {'key1' -> 'value1'. 'key2' -> 'value2'} as: Dictionary.
	stick endpoint hSet: 'testHSetWithDictionary' dictionary: dict.
	self assert: (stick endpoint hGetAll: 'testHSetWithDictionary') equals: dict.
	self
		assert: (stick endpoint hGet: 'testHSetWithDictionary' field: 'key1')
		equals: (dict at: 'key1')