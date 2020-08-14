commands-sets
sScan: aKey cursor: aCursor count: count match: matchPattern
	^ self
		unifiedCommand:
			{'SSCAN'.
			aKey.
			aCursor.
			'MATCH'.
			matchPattern.
			'COUNT'.
			count}