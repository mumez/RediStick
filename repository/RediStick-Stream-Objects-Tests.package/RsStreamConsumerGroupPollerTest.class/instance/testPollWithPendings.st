tests
testPollWithPendings
	| strm consumerGroup entries1 consumer1 poller1 pendings |
	strm := self newStreamNamed: 'testPollWithPendings'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	consumerGroup := strm consumerGroupNamed: 'group1'.
	
	entries1 := OrderedCollection new.
	consumer1 := consumerGroup consumerNamed: 'consumer1'.
	poller1 := consumer1 poller.
	poller1 onReceive: [ :each | entries1 add: (each content key asInteger / each content value asInteger)].
	poller1 start.
	
	#(1 2 3 0 4 5 6 7 0) doWithIndex: [ :each :idx | 
		strm nextPut: (idx  -> each).
	].
	(Delay forMilliseconds: 100) wait.
	self assert: entries1 size equals: 7.
	self assert: entries1 first equals: 1.
	self assert: entries1 last equals: (8/7).
	
	pendings := consumer1 allPendings.
	self assert: pendings size equals: 2.
	self assert: pendings first content key equals: '4'.
	self assert: pendings last content key equals: '9'.
	poller1 onReceive: [ :each | entries1 add: each ].
	
	[consumerGroup summaryPendingList isEmpty] whileFalse: [(Delay forMilliseconds: 100) wait].
	pendings := consumer1 allPendings.
	self assert: pendings size equals: 0.
	self assert: entries1 size equals: 9.
	
	poller1 stop.
	consumerGroup destroy.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	
	