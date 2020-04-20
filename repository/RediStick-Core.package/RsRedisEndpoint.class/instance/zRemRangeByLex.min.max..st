commands-sorted-sets
zRemRangeByLex: key min: min max: max 
	^ self 
		unifiedCommand:{ 'ZREMRANGEBYLEX'. key. min. max }