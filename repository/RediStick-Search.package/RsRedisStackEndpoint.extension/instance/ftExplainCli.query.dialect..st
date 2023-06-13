*RediStick-Search
ftExplainCli: indexName query: query dialect: dialect
	| args |
	args := OrderedCollection new.
	dialect ifNotNil: [
		args add: {
				'DIALECT'.
				dialect } ].
	^ self ftCommand: 'EXPLAINCLI' withAll: {
			  indexName.
			  query } , args