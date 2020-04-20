commands-generic
rename: oldKey to: newKey
	^ self
		unifiedCommand:
			{'RENAME'.
			oldKey.
			newKey}