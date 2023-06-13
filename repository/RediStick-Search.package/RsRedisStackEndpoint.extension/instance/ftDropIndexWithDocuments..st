*RediStick-Search
ftDropIndexWithDocuments: indexName
	^ self ftCommand: 'DROP' withAll: {indexName. 'DD'} 