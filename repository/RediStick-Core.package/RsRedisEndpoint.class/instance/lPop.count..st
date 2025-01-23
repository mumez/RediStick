commands-lists
lPop: aKey count: count
	^ self unifiedCommand: {
			  'LPOP'.
			  aKey.
			  count }