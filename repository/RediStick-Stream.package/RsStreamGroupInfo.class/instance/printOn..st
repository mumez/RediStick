printing
printOn: aStream
	aStream nextPutAll: 'name: '.
	self name printOn: aStream.
	aStream
		cr;
		nextPutAll: 'consumers: '.
	self consumers printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pending: '.
	self pending printOn: aStream.
	aStream
		cr;
		nextPutAll: 'lastDeliveredId: '.
	self lastDeliveredId printOn: aStream.
	aStream
		cr;
		nextPutAll: 'entriesRead: '.
	self entriesRead printOn: aStream.
	aStream
		cr;
		nextPutAll: 'lag: '.
	self lag printOn: aStream