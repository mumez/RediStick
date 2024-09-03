tests
testDeletes
	| strm one two three msgIds conts deletedCount |
	strm := self newStreamNamed: 'testDeletes'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	strm nextPut: one.
	msgIds := { two. three } collect: [:each | strm nextPut: each].
	
	conts := strm contents.
	self assert: conts size equals: 3.
	conts := strm first: 2.
	self assert: conts size equals: 2.
	self assert: conts first content equals: one.
	self assert: conts second content equals: two.
	
	deletedCount := strm deleteAtIds: msgIds.
	self assert: deletedCount equals: 2.
	conts := strm contents.
	self assert: conts size equals: 1.
	conts := strm first: 2.
	self assert: conts size equals: 1.
	self assert: conts first content equals: one.
	
	strm trimTo: 0.
	self assert: strm length equals: 0