accessing
content: anObject
	| val |
	val := anObject
		       ifNil: [ anObject ]
		       ifNotNil: [ Dictionary newFromPairs: anObject ].
	content := val