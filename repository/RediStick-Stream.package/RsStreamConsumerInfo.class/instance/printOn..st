printing
printOn: aStream
	aStream nextPutAll: 'name: '.
	self name printOn: aStream.
	aStream
		cr;
		nextPutAll: 'pending: '.
	self pending printOn: aStream.
	aStream
		cr;
		nextPutAll: 'idle: '.
	self idle printOn: aStream.
	aStream
		cr;
		nextPutAll: 'inactive: '.
	self inactive printOn: aStream