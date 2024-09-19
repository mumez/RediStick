instance creation
fromString: aString
	| tokens tokensSize |
	tokens := aString findTokens: '-'.
	tokensSize := tokens size.
	^ tokensSize = 2
		  ifTrue: [ self mainId: tokens first subId: tokens last ]
		  ifFalse: [ ^ self mainId: aString subId: nil ]