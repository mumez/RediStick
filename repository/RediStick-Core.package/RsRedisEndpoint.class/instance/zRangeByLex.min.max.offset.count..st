commands-sorted-sets
zRangeByLex: key min: min max: max offset: offset count: count
	^ self 
		unifiedCommand: {'ZRANGEBYLEX'. key. min. max. 'LIMIT'. offset. count }