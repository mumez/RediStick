commands-expiration
expire: aKey at: aDateAndTime
	^ self
		unifiedCommand:
			{'EXPIREAT'.
			aKey.
			(aDateAndTime asUnixTime)}