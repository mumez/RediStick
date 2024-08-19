actions
start
	self shouldKeepPolling ifTrue: [ ^self ].
	self shouldKeepPolling: true.
	pollingProcess := [self keepPolling] forkAt: self pollingPriority