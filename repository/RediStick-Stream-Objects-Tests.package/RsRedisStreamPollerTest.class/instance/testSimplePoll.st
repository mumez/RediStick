tests
testSimplePoll
	| strm sema entries1 poller1 entries2 poller2 one two three four five |
	strm := self newStreamNamed: 'testSimplePoll'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	sema := Semaphore new.
	entries1 := OrderedCollection new.
	poller1 := strm pollerIncoming.
	poller1 onReceive: [ :each | entries1 add: each. entries1 size = 5 ifTrue: [ sema signal ] ].
	poller1 start.
	poller2 := strm pollerIncoming.
	entries2 := OrderedCollection new.
	poller2 onReceive: [ :each | entries2 add: each. entries2 size = 5 ifTrue: [ sema signal ] ].
	poller2 start.
	
	(Delay forMilliseconds: 300) wait.
	
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	
	sema wait; wait.
	poller1 stop.
	poller2 stop.
	
	self assert: entries1 size equals: 5.
	self assert: entries2 size equals: 5.
	self assert: entries1 first content equals: one.
	self assert: entries2 first content equals: one.
	self assert: entries1 last content equals: five.
	self assert: entries2 last content equals: five.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	