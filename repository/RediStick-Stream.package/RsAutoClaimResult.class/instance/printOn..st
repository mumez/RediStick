printing
printOn: aStream
	aStream nextPutAll: 'nextId: '.
	self nextId printOn: aStream.
	aStream cr; nextPutAll: 'claimedMessages: '.
	self claimedMessages printOn: aStream.
	aStream cr; nextPutAll: 'deletedMessages: '.
	self deletedMessages printOn: aStream.