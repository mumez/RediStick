accessing
shouldKeepPolling
	^ shouldKeepPolling ifNil: [ shouldKeepPolling := true ]