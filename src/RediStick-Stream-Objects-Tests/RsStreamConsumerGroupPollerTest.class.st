Class {
	#name : 'RsStreamConsumerGroupPollerTest',
	#superclass : 'RsRedisStreamBaseTestCase',
	#category : 'RediStick-Stream-Objects-Tests',
	#package : 'RediStick-Stream-Objects-Tests'
}

{ #category : 'tests' }
RsStreamConsumerGroupPollerTest >> testGroupPollWithDelete [
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
	
	
]

{ #category : 'tests' }
RsStreamConsumerGroupPollerTest >> testPollWithPendings [
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
	
	
]

{ #category : 'tests' }
RsStreamConsumerGroupPollerTest >> testPollWithPendingsAutoClaimed [
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
	
	poller1 kill.
	
	entries2 := OrderedCollection new.
	consumer2 := consumerGroup consumerNamed: 'consumer2'.
	poller2 := consumer2 poller.
	poller2 onReceive: [ :each | entries2 add: each].
	poller2 shouldAutoClaim: true.
	poller2 claimMinIdleMilliseconds: 10.
	poller2 start.
	#(10 11 12) doWithIndex: [ :each :idx | 
		strm nextPut: (idx  -> each).
	].
	[consumerGroup summaryPendingList isEmpty] whileFalse: [(Delay forMilliseconds: 100) wait].

	self assert: consumer1 allPendings size equals: 0.
	self assert: consumer2 allPendings size equals: 0.
	self assert: entries2 size equals: 5.
	self assert: (entries2 collect: [:each | each content key]) sorted asArray equals: #('1' '2' '3' '4' '9').
	
	poller2 stop.
	consumerGroup destroy.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	
	
]

{ #category : 'tests' }
RsStreamConsumerGroupPollerTest >> testSimpleGroupNoAckPoll [

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
]

{ #category : 'tests' }
RsStreamConsumerGroupPollerTest >> testSimpleGroupPoll [
	| strm consumerGroup entries1 consumer1 poller1 entries2 consumer2 poller2 |
	strm := self newStreamNamed: 'testSimpleGroupPoll'.
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
	strm trimTo: 0.
	self assert: strm length equals: 0.
	
	
]
