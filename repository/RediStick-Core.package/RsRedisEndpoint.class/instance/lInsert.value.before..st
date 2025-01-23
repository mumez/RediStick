commands-lists
lInsert: aKey value: aValue before: pivot
	^ self unifiedCommand: {
			  'LINSERT'.
			  aKey.
			  'BEFORE'.
			  pivot.
			  aValue }