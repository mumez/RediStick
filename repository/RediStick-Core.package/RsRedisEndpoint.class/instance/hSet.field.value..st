commands-hashes
hSet: key field: field value: value 
	^ self unifiedCommand: {'HSET'. key. field. value}