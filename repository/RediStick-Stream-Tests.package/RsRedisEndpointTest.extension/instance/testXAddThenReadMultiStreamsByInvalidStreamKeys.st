*RediStick-Stream-Tests
testXAddThenReadMultiStreamsByInvalidStreamKeys
	| streamKey1 id1 streamKey2 id2 messagesDict size messages1 messages2 |
	streamKey1 := 'stream-testXAddThenReadMultiStreamsByInvalidStreamKeys-1'.
	stick endpoint xTrim: streamKey1 maxLen: 1000.
	stick endpoint xAdd: streamKey1 field: 'a' value: '1'.
	id1 := stick endpoint xAdd: streamKey1 field: 'b' value: '2'.
	stick endpoint xAdd: streamKey1 field: 'c' value: '3'.
	stick endpoint xAdd: streamKey1 field: 'd' value: '4'.
	stick endpoint xAdd: streamKey1 field: 'e' value: '5'.
	
	streamKey2 := 'stream-testXAddThenReadMultiStreamsByInvalidStreamKeys-2'.
	stick endpoint xTrim: streamKey2 maxLen: 1000.
	stick endpoint xAdd: streamKey2 field: 'aa' value: '11'.
	stick endpoint xAdd: streamKey2 field: 'bb' value: '22'.
	id2 := stick endpoint xAdd: streamKey2 field: 'cc' value: '33'.
	stick endpoint xAdd: streamKey2 field: 'dd' value: '44'.
	stick endpoint xAdd: streamKey2 field: 'ee' value: '55'.
	
	messagesDict := stick endpoint xReadKeysAndIds: {streamKey2 -> id2. '---invalid---' -> '9999999999999-0'. streamKey1 -> id1} count: 2.
	size := messagesDict size.
	self assert: size equals: 3.
	messages1 := messagesDict at: streamKey1.
	self assert: messages1 first fieldAndValue equals: 'c'->'3'.
	self assert: messages1 second fieldAndValue equals: 'd'->'4'.
	messages2 := messagesDict at: streamKey2.
	self assert: messages2 first fieldAndValue equals: 'dd'->'44'.
	self assert: messages2 second fieldAndValue equals: 'ee'->'55'.
	self assert: (messagesDict at: '---invalid---') size equals: 0

