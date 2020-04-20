commands-hashes
hExists: aKey field: aField 
	^ (self unifiedCommand: {'HEXISTS' . aKey. aField})
		= 1 