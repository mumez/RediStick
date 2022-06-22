actions
subscribeAllAndStart
	self initialize.
	RsRedisPubsubChannel initialize.
	^self default subscribeAllAndStart