commands-lists
rPush: aKey value: aValue 
	^ self
		unifiedCommand: { 'RPUSH'
		. aKey
		. aValue}