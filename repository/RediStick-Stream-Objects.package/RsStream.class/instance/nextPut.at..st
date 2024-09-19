adding
nextPut: keyValuesOrAssociation at: streamMessageId
	^ self nextPutAssociations: (self ensureAssociations: keyValuesOrAssociation) at: streamMessageId trimUsing: [:opts |]