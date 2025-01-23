commands-lists
lInsert: aKey value: aValue after: pivot
	^ self unifiedCommand: {
			  'LINSERT'.
			  aKey.
			  'AFTER'.
			  pivot.
			  aValue }