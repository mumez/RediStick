*RediStick-Search
ftUpdateAlias: alias of: indexName
	^ self ftCommand: 'ALIASUPDATE' withAll: {alias. indexName} 