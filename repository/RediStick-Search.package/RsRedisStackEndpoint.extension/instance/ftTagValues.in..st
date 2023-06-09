*RediStick-Search
ftTagValues: fieldName in: indexName
	^ self ftCommand: 'TAGVALS' withAll: {indexName. fieldName} 