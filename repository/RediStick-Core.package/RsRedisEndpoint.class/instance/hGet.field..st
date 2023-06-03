commands-hashes
hGet: aKey field: aField

	^ self unifiedCommand: {
			  'HGET'.
			  aKey.
			  aField }