adding
nextPutAll: keyValuesOrAssociations
	^ keyValuesOrAssociations collect: [ :each | self nextPut: each ]