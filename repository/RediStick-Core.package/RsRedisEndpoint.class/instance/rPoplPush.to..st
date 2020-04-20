commands-lists
rPoplPush: sourceKey to: destinationKey
	^ self
		unifiedCommand:
			{'RPOPLPUSH'.
			sourceKey.
			destinationKey}