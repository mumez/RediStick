test
testHMGetFields
	self endpoint hMSet: 'keyA' dictionary: redisHashDictionary.
	self
		assertCollection: (self endpoint hMGet: 'keyA' fields: redisHashDictionary keys)
		hasSameElements: redisHashDictionary values.
	self assert: (self endpoint hMGet: 'keyA' fields: #()) isNil.
	self assert: (self endpoint hMGet: 'unknowKey' fields: #()) isNil