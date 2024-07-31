tests
testSimplePoll
	| strm entries1 poller1 entries2 poller2 one two three four five |
	strm := self newStreamNamed: 'testSimplePoll'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	entries1 := OrderedCollection new.
	poller1 := strm pollerIncoming.
	poller1 onReceive: [ :each | entries1 add: each ].
	poller1 start.
	poller2 := strm pollerIncoming.
	entries2 := OrderedCollection new.
	poller2 onReceive: [ :each | entries2 add: each ].
	poller2 start.
	
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	
	(Delay forSeconds: 1) wait.
	poller1 stop.
	poller2 stop.
	
	self assert: entries1 size equals: 5.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	