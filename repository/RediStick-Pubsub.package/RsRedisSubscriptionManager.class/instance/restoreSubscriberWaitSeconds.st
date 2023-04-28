accessing
restoreSubscriberWaitSeconds
	^ (self intervalSeconds // 4) max: 3