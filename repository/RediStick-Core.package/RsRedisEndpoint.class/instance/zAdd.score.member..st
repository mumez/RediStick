commands-sorted-sets
zAdd: aKey score: aScore member: aMember
	^ self
		unifiedCommand:
			{'ZADD'.
			aKey.
			aScore.
			aMember}