printing
printOn: aStream
	self kind ifNotNil: [ 
		aStream nextPutAll: ('[', self kind, ']').
	].
	self channel ifNotNil: [ 
		aStream space; nextPutAll:  'Channel: '.
		aStream nextPutAll: self channel asString.
	].
	self numberOfChannels ifNotNil: [ 
		aStream space; nextPutAll:  'NumberOfChannels: '.
		aStream nextPutAll: self numberOfChannels asString.
	].
	self payload ifNotNil: [ 
		aStream space; nextPutAll:  'Payload: '.
		aStream nextPutAll: self payload asString.
	].
	
	