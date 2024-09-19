claiming
shouldAutoClaim: aBoolean
	aBoolean
		ifTrue: [ self autoClaimIfTrue: [ :c | true ] ]
		ifFalse: [ self shouldAutoClaimBlock: nil ]