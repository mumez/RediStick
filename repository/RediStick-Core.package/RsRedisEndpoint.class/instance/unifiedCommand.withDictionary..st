private
unifiedCommand: anArray withDictionary: aDictionary
	^ self unifiedCommand: anArray , (self keysValueInline: aDictionary)