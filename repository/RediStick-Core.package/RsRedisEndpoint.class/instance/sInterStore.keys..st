commands-sets
sInterStore: destinationKey keys: keys
	^ self
		unifiedCommand:
			{'SINTERSTORE'.
			destinationKey} , keys