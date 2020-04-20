commands-sorted-sets
zRevRangeByLex: key min: min max: max 
	^ self 
		unifiedCommand:{ 'ZREVRANGEBYLEX'. key. min. max }