*RediStick-Stream-Tests
testXGroupAddThenReadMultiple
	| streamKey groupKey consumerKeyA consumerKeyB created messagesA messagesB ack pendingSize destroyedSize |
	streamKey := 'stream-testXGroupAddThenReadMultiple'.
	groupKey := 'group-a'.
	consumerKeyA := 'consumer-a'.
	consumerKeyB := 'consumer-b'.
	
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	stick endpoint xAdd: streamKey field: 'b' value: '2'.
	
	created := stick endpoint xGroupCreate: streamKey group: groupKey id: 0 createNotExists: true.
	self assert: created equals: 'OK'.
	
	messagesA := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyA.
	self assert: messagesA size equals: 2.
	
	stick endpoint xAdd: streamKey field: 'c' value: '3'.	
	messagesB := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyB.
	self assert: messagesB size equals: 1.
	ack := stick endpoint xAck: streamKey group: groupKey id: messagesB first id.
	self assert: ack equals: 1.
	messagesB := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyB.
	self assert: messagesB size equals: 0.
	
	messagesA := stick endpoint xGroupRead: streamKey id: 0 group: groupKey consumer: consumerKeyA.
	self assert: messagesA size equals: 2.
	stick endpoint xAck: streamKey group: groupKey id: messagesA first id.
	stick endpoint xAck: streamKey group: groupKey id: messagesA last id.
	messagesA := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyA.
	self assert: messagesA size equals: 0.
	
	pendingSize := stick endpoint xGroupDelConsumer: streamKey group: groupKey consumer: consumerKeyA.
	self assert: pendingSize equals: 0.
	pendingSize := stick endpoint xGroupDelConsumer: streamKey group: groupKey consumer: consumerKeyB.
	self assert: pendingSize equals: 0.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.