factory
createSubscriber
	| redis |
	Transcript crShow: '-createSubscriber-'.
	redis := RsRediStick targetUrl: self targetUrl.
	redis endpoint settings receivingProcessPriority:
		Processor highIOPriority.
	redis onError: [ :ex | self restoreSubscriber: redis ].
	redis connect.
	^ redis