commands-strings
getSet: aKey value: aValue
	^ self
		unifiedCommand:
			{'GETSET'.
			aKey.
			aValue}