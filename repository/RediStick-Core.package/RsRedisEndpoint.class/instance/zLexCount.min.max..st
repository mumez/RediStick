commands-sorted-sets
zLexCount: key min: min max: max 
	^ self 
		unifiedCommand: {'ZLEXCOUNT'. key. min. max }