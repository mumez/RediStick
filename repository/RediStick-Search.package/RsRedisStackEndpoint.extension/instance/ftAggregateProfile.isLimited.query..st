*RediStick-Search
ftAggregateProfile: indexName isLimited: isLimited query: query
	^ self
		  ftProfile: indexName
		  type: 'AGGREGATE'
		  isLimited: isLimited
		  query: query