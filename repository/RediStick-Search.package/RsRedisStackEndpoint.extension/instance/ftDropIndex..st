*RediStick-Search
ftDropIndex: indexName
	^ self ftCommand: 'DROP' withAll: {indexName} 