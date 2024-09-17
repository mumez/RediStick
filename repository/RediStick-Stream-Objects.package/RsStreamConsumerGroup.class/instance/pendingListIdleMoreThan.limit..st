accessing-pending-list
pendingListIdleMoreThan: milliseconds limit: count
	^ self endpoint xPending: self streamName group: self name start: RsStreamMessageId min end: RsStreamMessageId max count: count minIdleMilliseconds: milliseconds