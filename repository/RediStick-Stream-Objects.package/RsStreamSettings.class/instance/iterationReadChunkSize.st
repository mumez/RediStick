accessing
iterationReadChunkSize
	^ self at: #iterationReadChunkSize ifAbsentPut: [20]