accessing
pollReadChunkSize
	^ self at: #pollReadChunkSize ifAbsentPut: [20]