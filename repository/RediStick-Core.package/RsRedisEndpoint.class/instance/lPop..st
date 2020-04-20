commands-lists
lPop: aKey
	^ self
		unifiedCommand:
			{'LPOP'.
			aKey}