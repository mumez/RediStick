private
claimPending
	self consumer autoClaimIdleMoreThan: self claimMinIdleMilliseconds.
	self updateLastClaimTimestamp