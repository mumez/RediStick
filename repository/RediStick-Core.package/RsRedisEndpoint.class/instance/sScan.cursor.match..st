commands-sets
sScan: aKey cursor: aCursor match: matchPattern
	^ self
		unifiedCommand:
			{'SSCAN'.
			aKey.
			aCursor.
			'MATCH'.
			matchPattern}