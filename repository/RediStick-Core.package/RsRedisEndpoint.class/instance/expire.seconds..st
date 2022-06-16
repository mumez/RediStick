commands-expiration
expire: aKey seconds: seconds
	^ self
		unifiedCommand:
			{'EXPIRE'.
			aKey.
			seconds}