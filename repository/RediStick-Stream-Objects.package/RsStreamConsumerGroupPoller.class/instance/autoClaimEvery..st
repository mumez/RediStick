claiming
autoClaimEvery: aDulation
	self updateLastClaimTimestamp.
	self autoClaimIfTrue: [ :c | (DateAndTime now - c lastClaimTimestamp) >= aDulation ]