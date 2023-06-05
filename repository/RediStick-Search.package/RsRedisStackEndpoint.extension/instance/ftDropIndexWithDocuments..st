*RediStick-Search
ftDropIndexWithDocuments: indexName
	^ self ftCommand: 'INDEX' withAll: {'DD'} 