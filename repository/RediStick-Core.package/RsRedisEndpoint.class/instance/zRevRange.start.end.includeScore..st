commands-sorted-sets
zRevRange: aKey start: aStart end: anEnd includeScore: shouldIncludeScore
	| args |
	args := shouldIncludeScore
		ifTrue: [ 
			{aKey.
			aStart.
			anEnd.
			'WITHSCORES'} ]
		ifFalse: [ 
			{aKey.
			aStart.
			anEnd} ].
	^ self unifiedCommand: {'ZREVRANGE'} , args