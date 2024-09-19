actions
kill
	pollingProcess ifNil: [ ^self ].
	pollingProcess terminate.
	shouldKeepPolling := false