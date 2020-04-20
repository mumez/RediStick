commands-lists
lTrim: aKey start: startIndex end: endIndex 
	^ self unifiedCommand: {'LTRIM'  .aKey. startIndex. endIndex}