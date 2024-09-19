actions
keepPolling
	[ self shouldKeepPolling ] whileTrue: [ self poll ]