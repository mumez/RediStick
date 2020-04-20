commands-lists
lIndex: aKey value: aValue
	^ self
		unifiedCommand:
			{'LINDEX'.
			aKey.
			aValue}