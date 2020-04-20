commands-sets
sRem: aKey member: aMember
	^ self
		unifiedCommand:
			{'SREM'.
			aKey.
			aMember}