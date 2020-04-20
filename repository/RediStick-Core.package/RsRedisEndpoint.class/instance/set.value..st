commands-strings
set: aKey value: aValue
	^ self
		unifiedCommand:
			{'SET'.
			aKey.
			aValue}