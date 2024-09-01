accessing-pending-list
pendingListAtMost: limit
	^ self pendingListFrom: RsStreamMessageId min end: RsStreamMessageId max atMost: limit