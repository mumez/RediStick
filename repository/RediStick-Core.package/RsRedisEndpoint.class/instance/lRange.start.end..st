commands-lists
lRange: aKey start: startIndex end: endIndex 
	^ self unifiedCommand: {'LRANGE' . aKey. startIndex. endIndex}