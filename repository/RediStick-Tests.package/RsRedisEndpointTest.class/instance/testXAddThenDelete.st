tests-stream
testXAddThenDelete
	| streamKey lastId size |
	streamKey := 'stream-testXAddThenDelete'.
	stick endpoint xAdd: streamKey field: 'a' value: 1.
	lastId := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	size := stick endpoint xLen: streamKey.
	self assert: size equals: 2.
	stick endpoint xDel: streamKey id: lastId.
	size := stick endpoint xLen: streamKey.
	self assert: size equals: 1.
	