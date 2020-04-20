commands-sets
sAdd: aKey member: aMember
	^ self
		unifiedCommand:
			{'SADD'.
			aKey.
			aMember}