*RediStick-Search
ftSearch: indexName query: query options: options 
	| args results |
	args := OrderedCollection new.
	options ifNotNil: [options createArgumentsOn: args].
	results := self ftCommand: 'SEARCH' withAll: {indexName. query}, args.
	^ RsSearchResultSet fromRawResults: results options: options