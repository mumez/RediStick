*RediStick-Search
ftAddAlias: alias of: indexName
	^ self ftCommand: 'ALIASADD' withAll: {alias. indexName} 