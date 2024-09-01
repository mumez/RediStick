accessing
claimReadChunkSize
	^ self at: #claimReadChunkSize ifAbsentPut: [20]