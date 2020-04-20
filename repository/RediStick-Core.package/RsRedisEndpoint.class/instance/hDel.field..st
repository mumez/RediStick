commands-hashes
hDel: aKey field: aField 
	^ self unifiedCommand: {'HDEL' . aKey. aField}