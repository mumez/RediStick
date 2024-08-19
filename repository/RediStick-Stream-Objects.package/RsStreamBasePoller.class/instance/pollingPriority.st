accessing
pollingPriority
	^ pollingPriority ifNil: [ pollingPriority := self defaultPollingPriority ].