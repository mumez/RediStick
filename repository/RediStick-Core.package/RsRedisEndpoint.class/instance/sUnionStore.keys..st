commands-sets
sUnionStore: destinationKey keys: keys
	^ self
		unifiedCommand:
			{'SUNIONSTORE'.
			destinationKey} , keys