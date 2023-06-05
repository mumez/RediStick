*RediStick-Search
ftGetConfig: optionName
	^ self ftCommand: 'CONFIG' withAll: {'GET'. optionName} 