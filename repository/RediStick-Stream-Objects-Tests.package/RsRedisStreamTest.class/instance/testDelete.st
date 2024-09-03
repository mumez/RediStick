tests
testDelete
	| strm one two three msgId conts deletedCount |
	strm := self newStreamNamed: 'testDelete'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	strm nextPut: one.
	msgId := strm nextPut: two.
	strm nextPut: three.
	
	conts := strm contents.
	self assert: conts size equals: 3.
	conts := strm first: 2.
	self assert: conts size equals: 2.
	self assert: conts first content equals: one.
	self assert: conts second content equals: two.
	
	deletedCount := strm deleteAt: msgId.
	self assert: deletedCount equals: 1.
	conts := strm contents.
	self assert: conts size equals: 2.
	conts := strm first: 2.
	self assert: conts size equals: 2.
	self assert: conts first content equals: one.
	self assert: conts second content equals: three.
	
	strm trimTo: 0.
	self assert: strm length equals: 0