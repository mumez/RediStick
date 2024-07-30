actions
start
	self shouldKeepPolling ifTrue: [ ^self ].
	self shouldKeepPolling: true.
	[self keepPolling] forkAt: self pollingPriority