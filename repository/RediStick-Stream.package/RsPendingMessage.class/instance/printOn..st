printing
printOn: aStream
	aStream nextPutAll: 'id: '.
	self id printOn: aStream.
	aStream cr; nextPutAll: 'consumerName: '.
	self consumerName printOn: aStream.
	aStream cr; nextPutAll: 'millisecondsFromLastDelivery: '.
	self millisecondsFromLastDelivery printOn: aStream.
	aStream cr; nextPutAll: 'deliveredCount: '.
	self deliveredCount printOn: aStream.