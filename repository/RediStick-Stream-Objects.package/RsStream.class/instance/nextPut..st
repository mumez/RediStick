adding
nextPut: keyValuesOrAssociation
	^ self nextPutAssociations: (self ensureAssociations: keyValuesOrAssociation)