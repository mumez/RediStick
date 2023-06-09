tests
testSearchWithOptionsSimpleHashes
	| ep schema rs content |
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
	
	rs := ep ftSearch: 'test-index' query: 'Visual*' optionsUsing: [:opts | opts noContent ].
	self assert: rs size equals: 2.
	self assert: (rs results collect: [:each | each content]) asArray equals: #(nil nil).
	self assert: rs documentIds sorted asArray equals: #('rs:test:doc:3' 'rs:test:doc:4').
	rs := ep ftSearch: 'test-index' query: 'Pharo' optionsUsing: [:opts | opts count ].
	self assert: rs size equals: 1.
	self assert: rs results isEmpty.
	
	rs := ep ftSearch: 'test-index' query: 'Pharo' optionsUsing: [:opts | opts withScores; withPayloads; withSortKeys ].
	self assert: rs size equals: 1.
	self assert: (rs result) score > 0.
	content := (rs result) content.
	self assert: (content at: 'id') equals: '1'.
	self assert: (content at: 'name') equals: 'Pharo Smalltalk'.
	
	ep ftDropIndexWithDocuments:'test-index'.
	self assert: ep ftListIndexes size equals: 0.