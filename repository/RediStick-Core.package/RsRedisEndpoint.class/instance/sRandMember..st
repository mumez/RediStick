commands-sets
sRandMember: aKey
	^ self
		unifiedCommand:
			{'SRANDMEMBER'.
			aKey}