commands-lists
lPushx: aKey value: aValue 
	^ self
		unifiedCommand: { 'LPUSHX'
		. aKey
		. aValue}