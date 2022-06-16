commands-expiration
persist: aKey
	"PERSIST key
Available since 2.2.0.
Time complexity: O(1)
Remove the existing timeout on key, turning the key from volatile (a key with an expire set) to persistent (a key that will never expire as no timeout is associated)."

	^ self
		unifiedCommand:
			{'PERSIST'.
			aKey}