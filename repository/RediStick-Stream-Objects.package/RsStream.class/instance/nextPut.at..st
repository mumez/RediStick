adding
nextPut: keyValueAssoc at: streamMessageId
	^ self nextPutAll: { keyValueAssoc } at: streamMessageId trimUsing: [:opts |]