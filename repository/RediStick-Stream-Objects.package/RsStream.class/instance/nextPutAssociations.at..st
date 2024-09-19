adding
nextPutAssociations: keyValueAssocs at: streamMessageId
	^ self nextPutAssociations: keyValueAssocs at: streamMessageId trimUsing: [:opts |]