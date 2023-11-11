printing
printOn: aStream
	aStream nextPutAll: self id.
	aStream nextPutAll: ':'.
	self fieldsAndValues asArray printOn: aStream