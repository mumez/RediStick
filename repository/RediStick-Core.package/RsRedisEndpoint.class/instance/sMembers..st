commands-sets
sMembers: aKey
	^ self
		unifiedCommand:
			{'SMEMBERS'.
			aKey}