factory
createSubscriberRediStick
	| redis |
	redis := RsRediStick targetUrl: self targetUrl.
	redis endpoint settings receivingProcessPriority: Processor highIOPriority.
	redis beSticky.
	redis connect.
	^ redis