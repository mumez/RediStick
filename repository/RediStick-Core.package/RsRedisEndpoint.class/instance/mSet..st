commands-strings
mSet: aDictionary
	^ self unifiedCommand: {'MSET'} , (self keysValueInline: aDictionary)