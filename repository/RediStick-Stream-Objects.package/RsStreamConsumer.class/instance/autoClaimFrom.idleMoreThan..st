claiming
autoClaimFrom: start idleMoreThan: milliseconds
	^ self autoClaimFrom: start idleMoreThan: milliseconds atMost: self settings claimReadChunkSize 