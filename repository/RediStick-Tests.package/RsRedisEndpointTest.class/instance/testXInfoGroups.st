tests-stream
testXInfoGroups
	| streamKey groupKey consumerKeyA consumerKeyB created ents1 ents2 groupInfoCol groupInfo lastDeliveredId destroyedSize |
	streamKey := 'stream-testXInfoGroups'.
	groupKey := 'group-a'.
	consumerKeyA := 'consumer-a'.
	consumerKeyB := 'consumer-b'.
	
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	self assert: (stick endpoint xLen: streamKey) equals: 3.
	
	created := stick endpoint xGroupCreate: streamKey group: groupKey id: 0 createNotExists: true.
	self assert: created equals: 'OK'.
	stick endpoint xGroupCreateConsumer: streamKey group: groupKey consumer: consumerKeyA.
	stick endpoint xGroupCreateConsumer: streamKey group: groupKey consumer: consumerKeyB.
	
	ents1 := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyA count: 1.
	ents2 := stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyB count: 2.
	stick endpoint xAck: streamKey group: groupKey id: ents1 first id.
	
	groupInfoCol := stick endpoint xInfoGroups: streamKey.
	self assert: groupInfoCol size equals: 1.
	groupInfo := groupInfoCol first.
	self assert: groupInfo name equals: groupKey.
	self assert: groupInfo consumers equals: 2.
	self assert: groupInfo pending equals: 2.
	lastDeliveredId := ents2 last id.
	self assert: groupInfo lastDeliveredId equals: lastDeliveredId.
	self assert: groupInfo entriesRead equals: 3.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.