claiming
autoClaimFrom: start idleMoreThan: milliseconds atMost: count on: consumerName
	^ self stream xAutoClaim: self streamName group: self name consumer: consumerName minIdleTime: milliseconds start: start count: count