tests-stream
testXInfoStream
	| streamKey groupKey consumerKeyA consumerKeyB created ents1 ents2 streamInfo destroyedSize |
	streamKey := 'stream-testXInfoStream'.
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
	
	streamInfo := stick endpoint xInfoStream: streamKey.
	self assert: streamInfo size equals: 3.
	self assert: streamInfo radixTreeKeys equals: 1.
	self assert: streamInfo radixTreeNodes equals: 2.
	self assert: streamInfo groups equals: 1.
	self assert: streamInfo lastGeneratedId equals: ents2 last id.
	self assert: streamInfo maxDeletedEntryId equals: '0-0'.
	self assert: streamInfo entriesAdded equals: 3.
	self assert: streamInfo firstEntry id equals: ents1 first id.
	self assert: streamInfo lastEntry id equals: ents2 last id.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.