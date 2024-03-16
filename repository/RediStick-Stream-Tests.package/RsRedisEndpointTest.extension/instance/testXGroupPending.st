*RediStick-Stream-Tests
testXGroupPending
	| streamKey groupKey consumerKeyA consumerKeyB created summary pendingsA pendingsB destroyedSize |
	streamKey := 'stream-testXGroupPending'.
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
	
	summary := stick endpoint xPending: streamKey group: groupKey.
	self assert: summary size equals: 0.
	
	stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyA count: 1.
	stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyB count: 2.
	
	summary := stick endpoint xPending: streamKey group: groupKey.
	self assert: (summary consumers at: consumerKeyA) equals: 1.
	self assert: (summary consumers at: consumerKeyB) equals: 2.
	
	pendingsA := stick endpoint xPending: streamKey group: groupKey start: '-' end: '+' count: 1 consumer: consumerKeyA.
	pendingsB := stick endpoint xPending: streamKey group: groupKey start: '-' end: '+' count: 2 consumer: consumerKeyB.
	self assert: (pendingsA size) equals: 1.
	self assert: (pendingsB size) equals: 2.
	self assert: (summary minId) equals: pendingsA first id.
	self assert: (summary maxId) equals: pendingsB last id.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.