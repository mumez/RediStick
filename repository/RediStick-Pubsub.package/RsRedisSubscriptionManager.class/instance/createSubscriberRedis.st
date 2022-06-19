factory
createSubscriberRedis
	| redis |
	redis := RsRediStick targetUrl: self targetUrl.
	redis endpoint settings receivingProcessPriority: Processor highIOPriority. 
	^ redis endpoint