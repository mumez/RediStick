commands-generic
expire: aKey at: aDateAndTime
	^ self
		unifiedCommand:
			{'EXPIREAT'.
			aKey.
			(aDateAndTime asUnixTime)}