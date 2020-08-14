commands-sets
sScan: aKey cursor: aCursor count: count
	^ self
		unifiedCommand:
			{'SSCAN'.
			aKey.
			aCursor.
			'COUNT'.
			count}