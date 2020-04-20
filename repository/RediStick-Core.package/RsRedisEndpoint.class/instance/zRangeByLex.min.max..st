commands-sorted-sets
zRangeByLex: key min: min max: max 
	^ self 
		unifiedCommand:{'ZRANGEBYLEX'. key. min. max }