commands-sorted-sets
zRem: aKey member: aMember
	^ self
		unifiedCommand:
			{'ZREM'.
			aKey.
			aMember}