tests
testSimpleConsume
	| strm one two three consumerGroup consumer1 entries pendingList moreEntries pendingEntries |
	strm := self newStreamNamed: 'testSimpleConsume'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	strm << one << two << three.
	consumerGroup := strm consumerGroupNamed: 'group1'.
	consumer1 := consumerGroup consumerNamed: 'consumer1'.
	entries := consumer1 neverDeliveredAtMost: 2.
	self assert: entries size equals: 2.
	self assert: entries first content equals: one.
	self assert: entries second content equals: two.
	pendingList := consumer1 pendingListAtMost: 5.
	self assert: pendingList size equals: 2.
	moreEntries := consumer1 neverDeliveredAtMost: 2.
	self assert: moreEntries size equals: 1.
	self assert: moreEntries first content equals: three.
	pendingEntries := consumer1 allPendings.
	self assert: pendingEntries size equals: 3.
	self assert: (consumer1 neverDeliveredAtMost: 2) size equals: 0.
	entries do: [ :each | each accept ].
	pendingEntries := consumer1 allPendings.
	self assert: pendingEntries size equals: 1.
	consumerGroup destroy.
	strm trimTo: 0.