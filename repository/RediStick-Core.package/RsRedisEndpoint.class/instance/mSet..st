commands-strings
mSet: aDictionary
	^ self unifiedCommand: {'MSET'} , (self keysAndValuesInlined: aDictionary)