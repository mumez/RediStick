tests
testSearchSimpleHashes
	| ep schema result content |
	ep := stick endpoint.
	self assert: ep ftListIndexes size equals: 0.
	schema := RsSearchIndexSchema in: [:sc |  
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	].
	ep ftCreate: 'test-index' schemaUsing: [:sc | 
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	] optionsUsing: [:opts | opts ].
	self assert: ep ftListIndexes size equals: 1.
	
	self populateDateOn: ep.
	
	result := ep ftSearch: 'test-index' query: 'Smalltalk'.
	self assert: result size equals: 4.
	
	result := ep ftSearch: 'test-index' query: 'Pharo'.
	self assert: result size equals: 1.
	content := (result results at: 1) content.
	self assert: (content at: 'id') equals: '1'.
	self assert: (content at: 'name') equals: 'Pharo Smalltalk'.
	
	result := ep ftSearch: 'test-index' query: 'Visual*'.
	self assert: result size equals: 2.
	
	ep ftDropIndexWithDocuments:'test-index'.
	self assert: ep ftListIndexes size equals: 0.