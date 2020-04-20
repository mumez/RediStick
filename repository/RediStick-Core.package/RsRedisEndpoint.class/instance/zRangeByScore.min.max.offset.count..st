commands-sorted-sets
zRangeByScore: aKey min: aMin max: aMax offset: anOffset count: aCount
	^ self
		unifiedCommand:
			{'ZRANGEBYSCORE'.
			aKey.
			aMin.
			aMax.
			'LIMIT'.
			anOffset.
			aCount}