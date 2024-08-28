claiming
autoClaimFrom: start idleMoreThan: milliseconds atMost: count on: consumerName
	^ self endpoint xAutoClaim: self streamName group: self name consumer: consumerName minIdleTime: milliseconds start: start count: count