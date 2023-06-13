*RediStick-Search
ftSearchProfile: indexName isLimited: isLimited query: query
	^ self
		  ftProfile: indexName
		  type: 'SEARCH'
		  isLimited: isLimited
		  query: query