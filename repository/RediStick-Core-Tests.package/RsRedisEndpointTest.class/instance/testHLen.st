test
testHLen
	self endpoint hMSet: 'keyA' dictionary: redisHashDictionary.
	self
		assert: (self endpoint hLen: 'keyA')
		equals: redisHashDictionary size