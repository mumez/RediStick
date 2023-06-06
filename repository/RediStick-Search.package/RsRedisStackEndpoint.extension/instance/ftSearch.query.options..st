*RediStick-Search
ftSearch: indexName query: query options: options 
	| args |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	^ self ftCommand: 'SEARCH' withAll: {indexName. query},  args 