commands-sets
getJSONAt: aKey
	^ self
		unifiedCommand:
			{'JSON.GET'.
			aKey}