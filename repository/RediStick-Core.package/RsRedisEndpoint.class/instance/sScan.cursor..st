commands-sets
sScan: aKey cursor: aCursor
	^ self
		unifiedCommand:
			{'SSCAN'.
			aKey.
			aCursor}