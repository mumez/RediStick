claiming
autoClaimIdsFrom: start idleMoreThan: milliseconds
	^ self autoClaimIdsFrom: start idleMoreThan: milliseconds atMost: self settings claimReadChunkSize 