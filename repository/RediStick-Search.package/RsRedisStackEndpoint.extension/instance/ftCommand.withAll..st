*RediStick-Search
ftCommand: commandName withAll: arguments

	^ self unifiedCommand: { ('FT.' , commandName) } , arguments