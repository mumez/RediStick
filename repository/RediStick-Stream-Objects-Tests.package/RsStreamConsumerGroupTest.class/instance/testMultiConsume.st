tests
testMultiConsume
	| strm one two three consumerGroup consumer1 consumer2 entries moreEntries pendingEntries |
	strm := self newStreamNamed: 'testMultiConsume'.
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
	consumer2 := consumerGroup consumerNamed: 'consumer2'.
	entries := consumer2 neverDeliveredAtMost: 1.
	self assert: entries size equals: 1.
	self assert: entries first content equals: three.	
	entries first accept.
	moreEntries := consumer1 neverDeliveredAtMost: 2.
	self assert: moreEntries size equals: 0.
	moreEntries := consumer2 neverDeliveredAtMost: 2.
	self assert: moreEntries size equals: 0.
	pendingEntries := consumer1 allPendings.
	self assert: pendingEntries size equals: 2.
	pendingEntries do: [ :each | each accept ].
	self assert: consumer1 allPendings size equals: 0.
	self assert: consumer2 allPendings size equals: 0.
	consumerGroup destroy.
	strm trimTo: 0.