testing
shouldAutoClaim
	shouldAutoClaimBlock ifNil: [ ^false ].
	^ self shouldAutoClaimBlock value: self