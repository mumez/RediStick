test
testHVals
	self endpoint hMSet: 'keyA' dictionary: redisHashDictionary.
	self
		assertCollection: (self endpoint hVals: 'keyA')
		hasSameElements: redisHashDictionary values