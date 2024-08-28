tests
testPollWithPendingsAutoClaimed
	| strm consumerGroup entries1 consumer1 poller1 pendings entries2 consumer2 poller2 |
	strm := self newStreamNamed: 'testPollWithPendingsAutoClaimed'.
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
	
	entries2 := OrderedCollection new.
	consumer2 := consumerGroup consumerNamed: 'consumer2'.
	poller2 := consumer2 poller.
	poller2 onReceive: [ :each | entries2 add: each].
	poller2 shouldAutoClaim: true.
	poller2 claimMinIdleMilliseconds: 10.
	poller2 start.
	#(10 11 12 13 14 15) doWithIndex: [ :each :idx | 
		strm nextPut: (idx  -> each).
	].
	[consumerGroup summaryPendingList isEmpty] whileFalse: [(Delay forMilliseconds: 100) wait].

	self assert: consumer1 allPendings size equals: 0.
	self assert: consumer2 allPendings size equals: 0.
	self assert: entries2 size equals: 8.
	
	poller1 stop.
	poller2 stop.
	consumerGroup destroy.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	
	