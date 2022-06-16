commands-expiration
pttl: aKey
	"Returns the remaining time to live of a key that has an expire set in milliseconds."

	^ self
		unifiedCommand:
			{'PTTL'.
			aKey}