commands-sorted-sets
zRevRangeByLex: key min: min max: max offset: offset count: count
	^ self 
		unifiedCommand: { 'ZREVRANGEBYLEX'. key. min. max. 'LIMIT'. offset. count }