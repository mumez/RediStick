commands-lists
rPop: aKey
	^ self
		unifiedCommand:
			{'RPOP'.
			aKey}