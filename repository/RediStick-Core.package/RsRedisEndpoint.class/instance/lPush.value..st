commands-lists
lPush: aKey value: aValue 
	^ self
		unifiedCommand: { 'LPUSH'
		. aKey
		. aValue}