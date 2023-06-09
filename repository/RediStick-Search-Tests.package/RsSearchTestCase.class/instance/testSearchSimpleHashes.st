tests
testSearchSimpleHashes
	| ep schema result |
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
	
	ep hSet:'rs:test:doc:1' dictionary: ({'id'-> 1. 'name'->'Pharo Smalltalk'} as: Dictionary).
	ep hSet:'rs:test:doc:2' dictionary: ({'id'-> 2. 'name'->'Squeak Smalltalk'} as: Dictionary).
	ep hSet:'rs:test:doc:3' dictionary: ({'id'-> 3. 'name'->'VisualWorks Smalltalk'} as: Dictionary).
	ep hSet:'rs:test:doc:4' dictionary: ({'id'-> 4. 'name'->'VisualAge Smalltalk'} as: Dictionary).
	
	result := ep ftSearch: 'test-index' query: 'Smalltalk'.
	"result inspect."
	
	result := ep ftSearch: 'test-index' query: 'Smalltalk' optionsUsing: [:opts | opts withScores; withPayloads; "withSortKeys;" noContent ].
	result inspect.
	
	result := ep ftSearch: 'test-index' query: 'Smalltalk' optionsUsing: [:opts | opts count ].
	"result inspect."
	
	ep ftDropIndexWithDocuments:'test-index'.
	self assert: ep ftListIndexes size equals: 0.