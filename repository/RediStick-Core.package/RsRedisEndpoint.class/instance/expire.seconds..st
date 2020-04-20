commands-generic
expire: aKey seconds: seconds
	^ self
		unifiedCommand:
			{'EXPIRE'.
			aKey.
			seconds}