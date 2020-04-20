commands-hashes
hLen: aKey
	^ self
		unifiedCommand:
			{'HLEN'.
			aKey}