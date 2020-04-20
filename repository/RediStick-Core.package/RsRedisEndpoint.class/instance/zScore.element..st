commands-sorted-sets
zScore: aKey element: anElement
	^ self
		unifiedCommand:
			{'ZSCORE'.
			aKey.
			anElement}