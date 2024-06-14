adding
nextPutAll: keyValueAssocs at: streamMessageId trimUsing: optionsBlock
	^ self endpoint
		  xAdd: self name
		  createNotExists: self autoCreate
		  trimUsing: optionsBlock
		  id: streamMessageId
		  fieldsAndValues: keyValueAssocs