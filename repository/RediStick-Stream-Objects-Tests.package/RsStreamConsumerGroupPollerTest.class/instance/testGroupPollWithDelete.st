tests
testGroupPollWithDelete
	| strm consumerGroup entries1 consumer1 poller1 entries2 consumer2 poller2 deletedIds leftIds |
	strm := self newStreamNamed: 'testGroupPollWithDelete'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	consumerGroup := strm consumerGroupNamed: 'group1'.
	
	entries1 := OrderedCollection new.
	consumer1 := consumerGroup consumerNamed: 'consumer1'.
	poller1 := consumer1 poller.
	poller1 onReceive: [ :each | entries1 add: each. (Delay forMilliseconds: 5) wait].
	poller1 start.
	consumer2 := consumerGroup consumerNamed: 'consumer2'.
	poller2 := consumer2 poller.
	poller2 shouldDeleteEntryAfterAcceptance: true.
	entries2 := OrderedCollection new.
	poller2 onReceive: [ :each | entries2 add: each. (Delay forMilliseconds: 5) wait].
	poller2 start.
	
	1 to: 10 do: [ :idx |
		strm nextPut: (('idx:', idx asString) -> idx).
	].
	(Delay forMilliseconds: 100) wait.
	[consumerGroup summaryPendingList isEmpty] whileFalse: [ (Delay forMilliseconds: 100) wait].
	
	poller1 stop.
	poller2 stop.
	
	self assert: entries1 size + entries2 size equals: 10.
	self assert: (entries1 intersection: entries2) size equals: 0.
	consumerGroup destroy.
	
	deletedIds := entries2 collect: [:each | each id].
	leftIds := strm contents collect: [:each | each id].
	self assert: deletedIds isEmpty equals: false.
	self assert: deletedIds size + leftIds size equals: 10.
	self assert: (leftIds includesAnyOf: deletedIds) equals: false.
	
	strm trimTo: 0.
	self assert: strm length equals: 0.
	
	