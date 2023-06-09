accessing
score: anObject
	| val |
	val := anObject isString
		       ifTrue: [ anObject asInteger ]
		       ifFalse: [ anObject ].
	score := val