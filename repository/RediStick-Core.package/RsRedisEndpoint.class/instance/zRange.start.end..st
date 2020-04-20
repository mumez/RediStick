commands-sorted-sets
zRange: aKey start: aStart end: anEnd 
	^ self
		zRange: aKey
		start: aStart
		end: anEnd
		includeScore: false