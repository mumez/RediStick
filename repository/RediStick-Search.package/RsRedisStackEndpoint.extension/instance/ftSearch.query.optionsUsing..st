*RediStick-Search
ftSearch: indexName query: query optionsUsing: optionsBuilder
	| options |
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchOptions in: optionsBuilder ].
	^ self ftSearch: indexName query: query options: options