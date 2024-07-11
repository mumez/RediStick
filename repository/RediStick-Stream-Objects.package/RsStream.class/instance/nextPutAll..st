adding
nextPutAll: keyValuesOrAssociations
	^ keyValuesOrAssociations do: [ :each | self nextPut: each ]