printing
printOn: aStream
	aStream nextPutAll: 'size: '.
	self size printOn: aStream.
	aStream cr; nextPutAll: 'minId: '.
	self minId printOn: aStream.
	aStream cr; nextPutAll: 'maxId: '.
	self maxId printOn: aStream.
	aStream cr; nextPutAll: 'consumers:'.
	self consumers printOn: aStream