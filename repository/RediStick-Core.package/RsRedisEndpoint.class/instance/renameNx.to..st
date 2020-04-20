commands-generic
renameNx: oldKey to: newKey
	^ self
		unifiedCommand:
			{'RENAMENX'.
			oldKey.
			newKey}