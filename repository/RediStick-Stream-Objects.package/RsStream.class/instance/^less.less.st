adding
<< keyValuesOrAssociation
	keyValuesOrAssociation isAssociation
		ifTrue: [ self nextPut: keyValuesOrAssociation ]
		ifFalse: [ self nextPutAssociations: keyValuesOrAssociation ]