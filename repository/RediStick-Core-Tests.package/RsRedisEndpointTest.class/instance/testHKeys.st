test
testHKeys
	self endpoint hMSet: 'keyA' dictionary: redisHashDictionary.
	self
		assertCollection: (self endpoint hKeys: 'keyA')
		hasSameElements: redisHashDictionary keys