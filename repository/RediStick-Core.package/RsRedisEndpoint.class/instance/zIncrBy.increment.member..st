commands-sorted-sets
zIncrBy: aKey increment: anIncrement member: aMember
	^ self
		unifiedCommand:
			{'ZINCRBY'.
			aKey.
			anIncrement.
			aMember}