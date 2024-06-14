adding
nextPutAll: keyValueAssocs at: streamMessageId
	^ self nextPutAll: keyValueAssocs at: streamMessageId trimUsing: [:opts |]