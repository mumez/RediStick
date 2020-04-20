commands-sets
sMove: sourceKey to: destinationKey member: aMember
	^ self
		unifiedCommand:
			{'SMOVE'.
			sourceKey.
			destinationKey.
			aMember}