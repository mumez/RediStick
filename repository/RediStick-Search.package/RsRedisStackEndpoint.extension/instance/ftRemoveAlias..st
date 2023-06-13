*RediStick-Search
ftRemoveAlias: alias
	^ self ftCommand: 'ALIASDEL' withAll: {alias} 