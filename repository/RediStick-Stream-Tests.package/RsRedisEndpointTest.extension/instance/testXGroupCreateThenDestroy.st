*RediStick-Stream-Tests
testXGroupCreateThenDestroy
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