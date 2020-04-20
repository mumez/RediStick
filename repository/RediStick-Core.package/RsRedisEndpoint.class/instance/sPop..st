commands-sets
sPop: aKey
	^ self
		unifiedCommand:
			{'SPOP'.
			aKey}