tests
testSearchWithLimitOffset
	| indexName ep rs |
	indexName := 'test-index3'.
	ep := stick endpoint.
	self assert: ep ftListIndexes size equals: 0.
	ep ftCreate: indexName schemaUsing: [:sc |
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	] optionsUsing: [:opts | opts prefixes: #('rs:test:smalltalk') ].
	self assert: ep ftListIndexes size equals: 1.
	
	self populateDateWithOtherPrefixesOn: ep.
	
	rs := ep ftSearch: indexName query: 'Smalltalk*' optionsUsing: [:opts | opts ].
	self assert: rs size equals: 10.
	self assert: (rs results allSatisfy: [:each | (each content at: 'name') beginsWith: 'Smalltalk' ]).
	
	rs := ep ftSearch: indexName query: 'Smalltalk*' optionsUsing: [:opts | opts limit: 3].
	self assert: rs size equals: 3.
	self assert: (rs results allSatisfy: [:each | (each content at: 'name') beginsWith: 'Smalltalk' ]).
	
	rs := ep ftSearch: indexName query: 'Smalltalk*' optionsUsing: [:opts | opts offset: 7 limit: 2].
	self assert: rs size equals: 2.
	self assert: (rs results collect: [:each | (each content at: 'name')]) asArray equals: #('Smalltalk8' 'Smalltalk9') .
	
	ep ftDropIndexWithDocuments: indexName.
	self assert: ep ftListIndexes size equals: 0.