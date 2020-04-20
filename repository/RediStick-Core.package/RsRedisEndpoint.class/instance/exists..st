commands-generic
exists: aKey
	^ (self
		unifiedCommand:
			{'EXISTS'.
			aKey}) = 1