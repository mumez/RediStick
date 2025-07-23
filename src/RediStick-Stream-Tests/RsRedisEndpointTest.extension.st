Extension { #name : 'RsRedisEndpointTest' }

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenDelete [
	| streamKey lastId size |
	streamKey := 'stream-testXAddThenDelete'.
	stick endpoint xAdd: streamKey field: 'a' value: 1.
	lastId := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	size := stick endpoint xLen: streamKey.
	self assert: size equals: 2.
	stick endpoint xDel: streamKey id: lastId.
	size := stick endpoint xLen: streamKey.
	self assert: size equals: 1.
	
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenRange [
	| streamKey id messages size |
	streamKey := 'stream-testXAddThenRange'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	id := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	stick endpoint xAdd: streamKey field: 'd' value: '4'.
	stick endpoint xAdd: streamKey field: 'e' value: '5'.
	
	messages := stick endpoint xRange: streamKey nextFrom: id count: 2.
	size := messages size.
	self assert: size equals: 2.
	
	self assert: messages first fieldAndValue equals: 'c'->'3'.
	self assert: messages second fieldAndValue equals: 'd'->'4'

]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenRangeAll [
	| streamKey messages size |
	streamKey := 'stream-testXAddThenRangeAll'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	stick endpoint xAdd: streamKey field: 'b' value: '2'.
	
	messages := stick endpoint xRangeAll: streamKey.
	size := messages size.
	self assert: size equals: 2.
	
	self assert: messages first fieldAndValue equals: 'a'->'1'.
	self assert: messages second fieldAndValue equals: 'b'->'2'

]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenRead [
	| streamKey id messages size |
	streamKey := 'stream-testXAddThenRead'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	id := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	stick endpoint xAdd: streamKey field: 'd' value: '4'.
	stick endpoint xAdd: streamKey field: 'e' value: '5'.
	
	messages := stick endpoint xRead: streamKey id: id count: 2.
	size := messages size.
	self assert: size equals: 2.
	
	self assert: messages first fieldAndValue equals: 'c'->'3'.
	self assert: messages second fieldAndValue equals: 'd'->'4'

]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenReadByInvalidId [
	| streamKey id messages size |
	streamKey := 'stream-testXAddThenReadByInvalidId'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	id := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	stick endpoint xAdd: streamKey field: 'd' value: '4'.
	stick endpoint xAdd: streamKey field: 'e' value: '5'.
	
	messages := stick endpoint xRead: streamKey id: '9999999999999-0' count: 2.
	size := messages size.
	self assert: size equals: 0.
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenReadByInvalidStreamKey [
	| streamKey id messages size |
	streamKey := 'stream-testXAddThenReadByInvalidStreamKey'.
	stick endpoint xTrim: streamKey maxLen: 1000.
	stick endpoint xAdd: streamKey field: 'a' value: '1'.
	id := stick endpoint xAdd: streamKey field: 'b' value: '2'.
	stick endpoint xAdd: streamKey field: 'c' value: '3'.
	stick endpoint xAdd: streamKey field: 'd' value: '4'.
	stick endpoint xAdd: streamKey field: 'e' value: '5'.
	
	messages := stick endpoint xRead: '---invalid---' id: id count: 2.
	size := messages size.
	self assert: size equals: 0.
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenReadMultiStreams [
	| streamKey1 id1 streamKey2 id2 messagesDict size messages1 messages2 |
	streamKey1 := 'stream-testXAddThenReadMultiStreams-1'.
	stick endpoint xTrim: streamKey1 maxLen: 1000.
	stick endpoint xAdd: streamKey1 field: 'a' value: '1'.
	id1 := stick endpoint xAdd: streamKey1 field: 'b' value: '2'.
	stick endpoint xAdd: streamKey1 field: 'c' value: '3'.
	stick endpoint xAdd: streamKey1 field: 'd' value: '4'.
	stick endpoint xAdd: streamKey1 field: 'e' value: '5'.
	
	streamKey2 := 'stream-testXAddThenReadMultiStreams-2'.
	stick endpoint xTrim: streamKey2 maxLen: 1000.
	stick endpoint xAdd: streamKey2 field: 'aa' value: '11'.
	stick endpoint xAdd: streamKey2 field: 'bb' value: '22'.
	id2 := stick endpoint xAdd: streamKey2 field: 'cc' value: '33'.
	stick endpoint xAdd: streamKey2 field: 'dd' value: '44'.
	stick endpoint xAdd: streamKey2 field: 'ee' value: '55'.
	
	messagesDict := stick endpoint xReadKeysAndIds: {streamKey1 -> id1. streamKey2 -> id2} count: 2.
	size := messagesDict size.
	self assert: size equals: 2.
	messages1 := messagesDict at: streamKey1.
	self assert: messages1 first fieldAndValue equals: 'c'->'3'.
	self assert: messages1 second fieldAndValue equals: 'd'->'4'.
	messages2 := messagesDict at: streamKey2.
	self assert: messages2 first fieldAndValue equals: 'dd'->'44'.
	self assert: messages2 second fieldAndValue equals: 'ee'->'55'

]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXAddThenReadMultiStreamsByInvalidStreamKeys [
	| streamKey1 id1 streamKey2 id2 messagesDict size messages1 messages2 |
	streamKey1 := 'stream-testXAddThenReadMultiStreamsByInvalidStreamKeys-1'.
	stick endpoint xTrim: streamKey1 maxLen: 1000.
	stick endpoint xAdd: streamKey1 field: 'a' value: '1'.
	id1 := stick endpoint xAdd: streamKey1 field: 'b' value: '2'.
	stick endpoint xAdd: streamKey1 field: 'c' value: '3'.
	stick endpoint xAdd: streamKey1 field: 'd' value: '4'.
	stick endpoint xAdd: streamKey1 field: 'e' value: '5'.
	
	streamKey2 := 'stream-testXAddThenReadMultiStreamsByInvalidStreamKeys-2'.
	stick endpoint xTrim: streamKey2 maxLen: 1000.
	stick endpoint xAdd: streamKey2 field: 'aa' value: '11'.
	stick endpoint xAdd: streamKey2 field: 'bb' value: '22'.
	id2 := stick endpoint xAdd: streamKey2 field: 'cc' value: '33'.
	stick endpoint xAdd: streamKey2 field: 'dd' value: '44'.
	stick endpoint xAdd: streamKey2 field: 'ee' value: '55'.
	
	messagesDict := stick endpoint xReadKeysAndIds: {streamKey2 -> id2. '---invalid---' -> '9999999999999-0'. streamKey1 -> id1} count: 2.
	size := messagesDict size.
	self assert: size equals: 3.
	messages1 := messagesDict at: streamKey1.
	self assert: messages1 first fieldAndValue equals: 'c'->'3'.
	self assert: messages1 second fieldAndValue equals: 'd'->'4'.
	messages2 := messagesDict at: streamKey2.
	self assert: messages2 first fieldAndValue equals: 'dd'->'44'.
	self assert: messages2 second fieldAndValue equals: 'ee'->'55'.
	self assert: (messagesDict at: '---invalid---') size equals: 0


]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXGroupAddThenRead [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXGroupAddThenReadMultiple [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXGroupAutoClaim [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXGroupClaim [
	| streamKey groupKey consumerKeyA consumerKeyB created summary pendingsB destroyedSize |
	streamKey := 'stream-testXGroupClaim'.
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
	
	stick endpoint xAck: streamKey group: groupKey id: summary minId.
	
	(Delay forMilliseconds: 200) wait.
	
	pendingsB := stick endpoint xPending: streamKey group: groupKey start: '-' end: '+' count: 2 consumer: consumerKeyB.
	stick endpoint xClaim: streamKey group: groupKey consumer: consumerKeyA minIdleTime: 10 id: pendingsB first id.
	
	summary := stick endpoint xPending: streamKey group: groupKey.
	
	self assert: (summary consumers at: consumerKeyA) equals: 1.
	self assert: (summary consumers at: consumerKeyB) equals: 1.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXGroupCreateThenDestroy [
	| streamKey groupKey consumerKey created createdSize pendingSize destroyedSize |
	streamKey := 'stream-testXGroupCreateThenDestroy'.
	groupKey := 'group-a'.
	consumerKey := 'consumer-a'.
	created := stick endpoint xGroupCreate: streamKey group: groupKey id: '$' createNotExists: true.
	self assert: created equals: 'OK'.
	createdSize := stick endpoint xGroupCreateConsumer: streamKey group: groupKey consumer: consumerKey.
	self assert: createdSize equals: 1.
	pendingSize := stick endpoint xGroupDelConsumer: streamKey group: groupKey consumer: consumerKey.
	self assert: pendingSize equals: 0.
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXGroupPending [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXInfoConsumers [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXInfoGroups [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXInfoStream [
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
]

{ #category : '*RediStick-Stream-Tests' }
RsRedisEndpointTest >> testXInfoStreamFull [
	| streamKey groupKey consumerKeyA consumerKeyB created ents1 ents2 streamInfo group consumers consumerA consumerB entries destroyedSize |
	streamKey := 'stream-testXInfoStreamFull'.
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
	
	streamInfo := stick endpoint xInfoStream: streamKey full: true count: 2.
	self assert: streamInfo size equals: 3.
	self assert: streamInfo radixTreeKeys equals: 1.
	self assert: streamInfo radixTreeNodes equals: 2.
	self assert: streamInfo groups size equals: 1.
	group := streamInfo groups first.
	self assert: group name equals: 'group-a'.
	self assert: group pelCount equals: 2.
	self assert: group entriesRead equals: 3.
	consumers := group consumers.
	consumerA := consumers detect: [ :e | e name = consumerKeyA ].
	self assert: consumerA pelCount equals: 0.
	self assert: consumerA pending size equals: 0.
	consumerB := consumers detect: [ :e | e name = consumerKeyB ].
	self assert: consumerB pelCount equals: 2.
	self assert: consumerB pending size equals: 2.
	self assert: consumerB pending last deliveredCount equals: 1.
	self assert: group lastDeliveredId equals: consumerB pending last id.
	self assert: streamInfo lastGeneratedId equals: ents2 last id.
	self assert: streamInfo maxDeletedEntryId equals: '0-0'.
	self assert: streamInfo entriesAdded equals: 3.
	entries := streamInfo entries.
	self assert: entries size equals: 2.
	self assert: entries first id equals: ents1 first id.
	self assert: (entries first fieldAt: 'a') equals: '1'.
	self assert: entries second id equals: ents2 first id.
	self assert: (entries second fieldAt: 'b') equals: '2'.
	self assert: streamInfo recordedFirstEntryId equals: ents1 first id.
	
	destroyedSize := stick endpoint xGroupDestroy: streamKey group: groupKey.
	self assert: destroyedSize equals: 1.
]
