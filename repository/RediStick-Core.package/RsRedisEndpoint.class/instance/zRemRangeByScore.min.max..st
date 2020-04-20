commands-sorted-sets
zRemRangeByScore: key min: min max: max
	^ self
		unifiedCommand:
			{'ZREMRANGEBYSCORE'.
			key.
			min.
			max}