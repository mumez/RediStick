commands-sets
sDiffStore: destinationKey keys: keys
	^ self
		unifiedCommand:
			{'SDIFFSTORE'.
			destinationKey} , keys