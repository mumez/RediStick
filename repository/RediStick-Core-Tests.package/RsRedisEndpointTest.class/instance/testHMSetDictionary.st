test
testHMSetDictionary
	self endpoint hMSet: 'keyA' dictionary: redisHashDictionary.
	self
		assertCollection: (self endpoint hGetAll: 'keyA')
		hasSameElements: redisHashDictionary