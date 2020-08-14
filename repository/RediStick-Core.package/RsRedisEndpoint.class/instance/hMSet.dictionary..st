commands-hashes
hMSet: aKey dictionary: aDictionary
	^ self
		unifiedCommand:
			{'HMSET'. aKey} , (self keysAndValuesInlined: aDictionary)

