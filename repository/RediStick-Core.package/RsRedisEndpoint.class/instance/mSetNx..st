commands-strings
mSetNx: aDictionary
	^ self unifiedCommand: {'MSETNX'} , (self flattenedKeysAndValuesFrom: aDictionary)