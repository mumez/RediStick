commands-sorted-sets
zCard: aKey
	^ self
		unifiedCommand:
			{'ZCARD'.
			aKey}