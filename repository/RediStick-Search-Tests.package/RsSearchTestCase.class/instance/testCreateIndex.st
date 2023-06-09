tests
testCreateIndex
	| ep schema indexInfo |
	ep := stick endpoint.
	self assert: ep ftListIndexes size equals: 0.
	schema := RsSearchIndexSchema in: [:sc |  
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	].
	ep ftCreate: 'test-index' schemaUsing: [:sc | 
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	] optionsUsing: [:opts | 
		opts language: 'english'.
		opts temporary: 10.
	].
	self assert: ep ftListIndexes size equals: 1.
	indexInfo := ep ftInfo: 'test-index'.
	self assert: (indexInfo at: 'index-name') equals: 'test-index'.
	self assert: (indexInfo at: 'attbibutes') size equals: 2.
	ep ftDropIndex: 'test-index'.
	self assert: ep ftListIndexes size equals: 0.