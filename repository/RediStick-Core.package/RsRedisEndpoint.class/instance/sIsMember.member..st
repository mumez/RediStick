commands-sets
sIsMember: aKey member: aMember
	^ (self
		unifiedCommand:
			{'SISMEMBER'.
			aKey.
			aMember}) = 1