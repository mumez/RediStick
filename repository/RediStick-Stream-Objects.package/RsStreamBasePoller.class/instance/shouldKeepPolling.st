accessing
shouldKeepPolling
	^ shouldKeepPolling ifNil: [ shouldKeepPolling := false ]