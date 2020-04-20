commands-sorted-sets
zRemRangeByRank: key start: start end: end
	^ self
		unifiedCommand:
			{'ZREMRANGEBYRANK'.
			key.
			start.
			end}