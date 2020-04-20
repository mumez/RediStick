commands-hashes
hMSet: aKey dictionary: aDictionary
	^ self
		unifiedCommand:
			{'HMSET'.
			aKey} , aDictionary flattened