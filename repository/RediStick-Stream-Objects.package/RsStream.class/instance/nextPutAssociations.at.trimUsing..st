adding
nextPutAssociations: keyValueAssocs at: streamMessageId trimUsing: optionsBlock
	^ RsStreamMessageId fromStringOrNil: (self endpoint
			   xAdd: self name
			   createNotExists: self autoCreate
			   trimUsing: optionsBlock
			   id: streamMessageId
			   fieldsAndValues: keyValueAssocs)