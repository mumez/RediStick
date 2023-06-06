*RediStick-Search
ftCreate: indexName schemaUsing: schemaBuilder optionsUsing: optionsBuilder
	| schema options |
	schema := RsSearchIndexSchema in: schemaBuilder.
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchIndexOptions in: optionsBuilder ].
	^ self ftCreate: indexName schema: schema options: options