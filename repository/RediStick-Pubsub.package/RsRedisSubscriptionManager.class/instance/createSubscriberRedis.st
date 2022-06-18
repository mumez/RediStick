accessing
createSubscriberRedis
	| redis |
	redis := RsRedis new.
	redis endpoint settings receivingProcessPriority: Processor highIOPriority. 
	^redis