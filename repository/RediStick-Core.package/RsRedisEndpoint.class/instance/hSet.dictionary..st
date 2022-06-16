commands-hashes
hSet: key dictionary: aDict
	^ self unifiedCommand: {'HSET'. key} , (self flattenedKeysAndValuesFrom: aDict)