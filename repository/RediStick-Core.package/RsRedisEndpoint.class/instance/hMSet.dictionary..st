commands-hashes
hMSet: aKey dictionary: aDictionary
	^ self
		unifiedCommand:
			{'HMSET'.
			aKey} , (self keysValueInline: aDictionary)