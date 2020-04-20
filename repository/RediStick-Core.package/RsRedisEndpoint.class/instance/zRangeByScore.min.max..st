commands-sorted-sets
zRangeByScore: aKey min: aMin max: aMax
	^ self
		unifiedCommand:
			{'ZRANGEBYSCORE'.
			aKey.
			aMin.
			aMax}