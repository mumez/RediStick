commands-lists
lSet: aKey index: anIndex value: aValue 
	^ self unifiedCommand: {'LSET' .aKey. anIndex. aValue}