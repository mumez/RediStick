factory
createSubscriber
	| redis |
	redis := RsRediStick targetUrl: self targetUrl.
	redis endpoint settings receivingProcessPriority:
		Processor highIOPriority.
	redis onError: [ :ex | self restoreSubscriber ].
	redis connect.
	^ redis