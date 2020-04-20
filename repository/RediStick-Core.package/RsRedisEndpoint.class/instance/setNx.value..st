commands-strings
setNx: aKey value: aValue
	^ self
		unifiedCommand:
			{'SETNX'.
			aKey.
			aValue}