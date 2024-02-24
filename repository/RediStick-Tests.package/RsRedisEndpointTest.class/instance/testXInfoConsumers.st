tests-stream
testXInfoConsumers
	| streamKey groupKey consumerKeyA consumerKeyB created ents1 ents2 consumerInfoCol consumerInfoA consumerInfoB destroyedSize |
	streamKey := 'stream-testXInfoConsumers'.
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
	(Delay forMilliseconds: 100) wait.
	
	consumerInfoCol := stick endpoint xInfoConsumers: streamKey group: groupKey.
	self assert: consumerInfoCol size equals: 2.
	
	consumerInfoA := consumerInfoCol detect: [ :each | each name = consumerKeyA ] ifNone:[].
	self assert: consumerInfoA pending equals: 0.
	self assert: consumerInfoA idle > 100 equals: true.
	self assert: consumerInfoA inactive > 100 equals: true.
	
	consumerInfoB := consumerInfoCol detect: [ :each | each name = consumerKeyB ] ifNone:[].
	self assert: consumerInfoB pending equals: 2.
	self assert: consumerInfoB idle > 100 equals: true.
	self assert: consumerInfoB inactive > 100 equals: true.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.