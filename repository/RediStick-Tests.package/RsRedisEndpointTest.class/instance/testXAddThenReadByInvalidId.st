tests-stream
testXAddThenReadByInvalidId
	| streamKey id messages size |
	streamKey := 'stream-testXAddThenReadByInvalidId'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	id := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	stick endpoint xAdd: streamKey field: 'd' value: '4'.
	stick endpoint xAdd: streamKey field: 'e' value: '5'.
	
	messages := stick endpoint xRead: streamKey id: '9999999999999-0' count: 2.
	size := messages size.
	self assert: size equals: 0.