Class {
	#name : 'RsSearchTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-Search-Tests',
	#package : 'RediStick-Search-Tests'
}

{ #category : 'accessing' }
RsSearchTest class >> dbIndex [
	"RediSearch only supports 0"
	^ 0
]

{ #category : 'accessing' }
RsSearchTest class >> urlString [
	^ super urlString ifNotNil: [ :str | str copyReplaceAll: 'sync:' with: 'stack:' ]
]

{ #category : 'private' }
RsSearchTest >> populateDateOn: endpoint [
	endpoint hSet:'rs:test:doc:1' dictionary: ({'id'-> 1. 'name'->'Pharo Smalltalk'} as: Dictionary).
	endpoint hSet:'rs:test:doc:2' dictionary: ({'id'-> 2. 'name'->'Squeak Smalltalk'} as: Dictionary).
	endpoint hSet:'rs:test:doc:3' dictionary: ({'id'-> 3. 'name'->'VisualWorks Smalltalk'} as: Dictionary).
	endpoint hSet:'rs:test:doc:4' dictionary: ({'id'-> 4. 'name'->'VisualAge Smalltalk'} as: Dictionary).
]

{ #category : 'private' }
RsSearchTest >> populateDateWithOtherPrefixesOn: endpoint [
	| otherPrefix |
	self populateDateOn: endpoint.
	otherPrefix := 'rs:test:smalltalk'.
	1 to: 10 do: [ :idx |
		endpoint hSet: (otherPrefix, idx asString) dictionary: 
			({'id'-> idx. 'name'-> ('Smalltalk', idx asString)} as: Dictionary).	
	]
]

{ #category : 'running' }
RsSearchTest >> setUp [
	super setUp.
	stick onRedisGenericError: [:ex| ex pass].
]

{ #category : 'tests' }
RsSearchTest >> testCreateIndex [
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
	self assert: (indexInfo at: 'index_name') equals: 'test-index'.
	self assert: (indexInfo at: 'attributes') size equals: 2.
	ep ftDropIndex: 'test-index'.
	self assert: ep ftListIndexes size equals: 0.
]

{ #category : 'tests' }
RsSearchTest >> testSearchSimpleHashes [
	| indexName ep rs content |
	indexName := 'test-index1'.
	ep := stick endpoint.
	self assert: ep ftListIndexes size equals: 0.
	ep ftCreate: indexName schemaUsing: [:sc | 
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	] optionsUsing: [:opts | opts ].
	self assert: ep ftListIndexes size equals: 1.
	
	self populateDateOn: ep.
	
	rs := ep ftSearch: indexName query: 'Smalltalk'.
	self assert: rs size equals: 4.
	
	rs := ep ftSearch: indexName query: 'Pharo'.
	self assert: rs size equals: 1.
	content := (rs results at: 1) content.
	self assert: (content at: 'id') equals: '1'.
	self assert: (content at: 'name') equals: 'Pharo Smalltalk'.
	
	rs := ep ftSearch: indexName query: 'Visual*'.
	self assert: rs size equals: 2.
	rs := ep ftSearch: indexName query: '"VisualWorks Smalltalk"'.
	self assert: rs size equals: 1.
	
	ep ftDropIndexWithDocuments: indexName.
	self assert: ep ftListIndexes size equals: 0.
]

{ #category : 'tests' }
RsSearchTest >> testSearchWithFieldQuery [
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
]

{ #category : 'tests' }
RsSearchTest >> testSearchWithLimitOffset [
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
]

{ #category : 'tests' }
RsSearchTest >> testSearchWithOptionsSimpleHashes [
	| indexName ep rs content |
	indexName := 'test-index1'.
	ep := stick endpoint.
	self assert: ep ftListIndexes size equals: 0.
	ep ftCreate: indexName schemaUsing: [:sc | 
		sc textFieldNamed: 'name'.
		sc numericFieldNamed: 'id'.
	] optionsUsing: [:opts | opts ].
	self assert: ep ftListIndexes size equals: 1.
	
	self populateDateOn: ep.
	
	rs := ep ftSearch: indexName query: 'Visual*' optionsUsing: [:opts | opts noContent ].
	self assert: rs size equals: 2.
	self assert: (rs results collect: [:each | each content]) asArray equals: { nil. nil }.
	self assert: rs documentIds sorted asArray equals: #('rs:test:doc:3' 'rs:test:doc:4').
	rs := ep ftSearch: indexName query: 'Pharo' optionsUsing: [:opts | opts count ].
	self assert: rs total equals: 1.
	self assert: rs results isEmpty.
	
	rs := ep ftSearch: indexName query: 'Pharo' optionsUsing: [:opts | opts withScores; withPayloads; withSortKeys ].
	self assert: rs size equals: 1.
	self assert: (rs result) score > 0.
	content := (rs result) content.
	self assert: (content at: 'id') equals: '1'.
	self assert: (content at: 'name') equals: 'Pharo Smalltalk'.
	
	ep ftDropIndexWithDocuments: indexName.
	self assert: ep ftListIndexes size equals: 0.
]
