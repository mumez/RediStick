*RediStick-Stream-Tests
testXGroupAddThenRead
	| streamKey groupKey consumerKeyA created messages size pendingSize destroyedSize |
	streamKey := 'stream-testXGroupAddThenRead'.
	groupKey := 'group-a'.
	consumerKeyA := 'consumer-a'.
	
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	
	created := stick endpoint xGroupCreate: streamKey group: groupKey id: 0 createNotExists: true.
	self assert: created equals: 'OK'.
	
	messages := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyA.
	size := messages size.
	self assert: size equals: 1.
	
	pendingSize := stick endpoint xGroupDelConsumer: streamKey group: groupKey consumer: consumerKeyA.
	self assert: pendingSize equals: 1.
	
	stick endpoint xAck: streamKey group: groupKey id: messages first id.
	
	pendingSize := stick endpoint xGroupDelConsumer: streamKey group: groupKey consumer: consumerKeyA.
	self assert: pendingSize equals: 0.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.