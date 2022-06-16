commands-expiration
ttl: aKey
	^ self
		unifiedCommand:
			{'TTL'.
			aKey}