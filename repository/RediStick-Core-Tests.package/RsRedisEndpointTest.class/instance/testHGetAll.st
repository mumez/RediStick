test
testHGetAll
	self endpoint hMSet: 'keyA' dictionary: redisHashDictionary.
	self
		assertCollection: (self endpoint hGetAll: 'keyA')
		equals: redisHashDictionary