commands-hashes
hIncrBy: key field: field value: value 
	^ self unifiedCommand:  {'HINCRBY'. key. field. value}
	