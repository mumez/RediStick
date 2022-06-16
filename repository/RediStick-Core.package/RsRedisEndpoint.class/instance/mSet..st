commands-strings
mSet: aDictionary
	^ self unifiedCommand: {'MSET'} , (self flattenedKeysAndValuesFrom: aDictionary )