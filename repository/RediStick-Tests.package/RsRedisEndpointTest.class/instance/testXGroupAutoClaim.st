tests-stream
testXGroupAutoClaim
	| streamKey groupKey consumerKeyA consumerKeyB created summary claimedA claimedB destroyedSize |
	streamKey := 'stream-testXGroupAutoClaim'.
	groupKey := 'group-a'.
	consumerKeyA := 'consumer-a'.
	consumerKeyB := 'consumer-b'.
	
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	stick endpoint xAdd: streamKey field: 'd' value: '4'.
	stick endpoint xAdd: streamKey field: 'e' value: '5'.
	self assert: (stick endpoint xLen: streamKey) equals: 5.
	
	created := stick endpoint xGroupCreate: streamKey group: groupKey id: 0 createNotExists: true.
	self assert: created equals: 'OK'.
	stick endpoint xGroupCreateConsumer: streamKey group: groupKey consumer: consumerKeyA.
	stick endpoint xGroupCreateConsumer: streamKey group: groupKey consumer: consumerKeyB.
	
	summary := stick endpoint xPending: streamKey group: groupKey.
	self assert: summary size equals: 0.
	
	stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyA count: 1.
	stick endpoint xGroupRead: streamKey id: '>' group: groupKey consumer: consumerKeyB count: 4.
	
	summary := stick endpoint xPending: streamKey group: groupKey.
	self assert: (summary consumers at: consumerKeyA) equals: 1.
	self assert: (summary consumers at: consumerKeyB) equals: 4.
	stick endpoint xAck: streamKey group: groupKey id: summary minId.
	(Delay forMilliseconds: 200) wait.
	
	claimedA := stick endpoint xAutoClaim: streamKey group: groupKey consumer: consumerKeyA minIdleTime: 10 start: summary minId count: 1 idsOnly: true.
	self deny: claimedA nextId equals: '0-0'.
	self assert: claimedA claimedMessages size equals: 1.
	self assert: claimedA deletedMessages size equals: 0.
	self assert: (claimedA claimedMessages allSatisfy: [ :each | each isString ]) equals: true.
	
	claimedB := stick endpoint xAutoClaim: streamKey group: groupKey consumer: consumerKeyA minIdleTime: 10 start: summary minId.
	self assert: claimedB nextId equals: '0-0'.
	self assert: claimedB claimedMessages size equals: 3.
	self assert: claimedB deletedMessages size equals: 0.
	
	summary := stick endpoint xPending: streamKey group: groupKey.
	self assert: (summary consumers at: consumerKeyA) equals: 4.
	self assert: (summary consumers at: consumerKeyB ifAbsent:[0]) equals: 0.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.