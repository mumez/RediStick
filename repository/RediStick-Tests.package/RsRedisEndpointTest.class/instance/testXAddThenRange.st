tests-stream
testXAddThenRange
	| streamKey messages size |
	streamKey := 'stream-testXAddThenRange'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	stick endpoint xAdd: streamKey field: 'b' value: '2'.
	
	messages := stick endpoint xRangeAll: streamKey.
	size := messages size.
	self assert: size equals: 2.
	
	self assert: messages first fieldAndValue equals: 'a'->'1'.
	self assert: messages second fieldAndValue equals: 'b'->'2'
