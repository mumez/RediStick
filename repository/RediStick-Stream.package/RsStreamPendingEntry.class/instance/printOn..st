printing
printOn: aStream
	aStream nextPutAll: 'id: '.
	self id printOn: aStream.
	aStream
		cr;
		nextPutAll: 'owner: '.
	self owner printOn: aStream.
	aStream
		cr;
		nextPutAll: 'deliveredTimestamp: '.
	self deliveredTimestamp printOn: aStream.
	aStream
		cr;
		nextPutAll: 'deliveredCount: '.
	self deliveredCount printOn: aStream