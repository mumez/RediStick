factory
prepareSubscriber
	| stick |
	stick := RsRediStick targetUrl: self targetUrl.
	subscriber := stick.
	stick endpoint settings receivingProcessPriority:
		Processor highIOPriority.
	stick onError: [ :ex | self restoreSubscriber: stick ].
	stick connect