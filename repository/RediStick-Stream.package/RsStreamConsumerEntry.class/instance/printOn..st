printing
printOn: aStream
	aStream nextPutAll: 'name: '.
	self name printOn: aStream.
	aStream
		cr;
		nextPutAll: 'seenTime: '.
	self seenTime printOn: aStream.
	aStream
		cr;
		nextPutAll: 'activeTime: '.
	self activeTime printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pelCount: '.
	self pelCount printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pending: '.
	self pending printOn: aStream.
	
	