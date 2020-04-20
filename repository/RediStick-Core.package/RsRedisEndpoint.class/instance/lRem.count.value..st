commands-lists
lRem: aKey count: aCount value: aValue 
	^ self unifiedCommand: {'LREM' .aKey. aCount. aValue}