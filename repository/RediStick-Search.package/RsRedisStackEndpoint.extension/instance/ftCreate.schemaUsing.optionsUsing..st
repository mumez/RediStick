*RediStick-Search
ftCreate: indexName schemaUsing: schemaBuilder optionsUsing: optionsBuilder
	| schema options |
	schema := RsSearchIndexSchema in: schemaBuilder.
	options := nil.
	optionsBuilder ifNotNil: [
		options := RsSearchIndexOptions in: schemaBuilder ].
	^ self ftCreate: indexName schema: schema options: options