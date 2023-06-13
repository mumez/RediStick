*RediStick-Search
ftSetConfig: optionName to: value
	^ self ftCommand: 'CONFIG' withAll: {'SET'. optionName. value} 