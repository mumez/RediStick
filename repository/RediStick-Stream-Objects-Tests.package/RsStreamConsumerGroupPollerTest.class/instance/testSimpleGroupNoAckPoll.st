tests
testSimpleGroupNoAckPoll

	| strm consumerGroup entries1 consumer1 poller1 entries2 consumer2 poller2 |
	strm := self newStreamNamed: 'testSimpleGroupNoAckPoll'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	consumerGroup := strm consumerGroupNamed: 'group1'.

	entries1 := OrderedCollection new.
	consumer1 := consumerGroup consumerNamed: 'consumer1'.
	poller1 := consumer1 noAckPoller.
	poller1 onReceive: [ :each | entries1 add: each. (Delay forMilliseconds: 3) wait ].
	poller1 start.
	consumer2 := consumerGroup consumerNamed: 'consumer2'.
	poller2 := consumer2 noAckPoller.
	entries2 := OrderedCollection new.
	poller2 onReceive: [ :each | entries2 add: each. (Delay forMilliseconds: 3) wait ].
	poller2 start.

	1 to: 10 do: [ :idx | strm nextPut: ('idx:' , idx asString) -> idx ].
	self assert: consumerGroup summaryPendingList size equals: 0.
	
	(Delay forMilliseconds: 100) wait.
	self assert: entries1 size + entries2 size > 0.

	poller1 stop.
	poller2 stop.

	consumerGroup destroy.
	strm trimTo: 0.
	self assert: strm length equals: 0