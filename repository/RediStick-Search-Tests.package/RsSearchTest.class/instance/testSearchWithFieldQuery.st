tests
testSearchWithFieldQuery
	| indexName ep rs |
	indexName := 'test-index2'.
	ep := stick endpoint.
	self assert: ep ftListIndexes size equals: 0.
	ep ftCreate: indexName schemaUsing: [:sc | 
		sc tagFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	] optionsUsing: [:opts | opts ].
	self assert: ep ftListIndexes size equals: 1.
	
	self populateDateOn: ep.
	
	rs := ep ftSearch: indexName query: '@id:[1 1]' optionsUsing: [:opts | opts noContent ].
	self assert: rs size equals: 1.
	self assert: rs documentIds sorted asArray equals: #('rs:test:doc:1').
	rs := ep ftSearch: indexName query: '@id:[1 3]' optionsUsing: [:opts | opts noContent ].
	self assert: rs size equals: 3.
	self assert: rs documentIds sorted asArray equals: #('rs:test:doc:1' 'rs:test:doc:2' 'rs:test:doc:3').
	
	rs := ep ftSearch: indexName query: '@name:{ Pharo Smalltalk }' optionsUsing: [:opts | opts noContent ].
	self assert: rs size equals: 1.
	self assert: rs documentIds sorted asArray equals: #('rs:test:doc:1').
	
	rs := ep ftSearch: indexName query: '@name:{ VisualWorks Smalltalk | VisualAge Smalltalk }' optionsUsing: [:opts | opts noContent ].
	self assert: rs size equals: 2.
	self assert: rs documentIds sorted asArray equals: #('rs:test:doc:3' 'rs:test:doc:4').
	
	ep ftDropIndexWithDocuments: indexName.
	self assert: ep ftListIndexes size equals: 0.