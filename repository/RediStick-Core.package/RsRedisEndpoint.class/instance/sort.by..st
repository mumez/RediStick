commands-sorting
sort: aKey by: aPattern
	^ self
		unifiedCommand:
			{'SORT'.
			aKey.
			'BY'.
			aPattern}