commands-sorted-sets
zRevRange: aKey start: aStart end: anEnd 
	^ self
		zRevRange: aKey
		start: aStart
		end: anEnd
		includeScore: false