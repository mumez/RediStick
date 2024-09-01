tests
testNextPut
	| strm conts first second third |
	strm := self newStreamNamed: 'testNextPut'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	first := 'one' -> '1'.
	second := 'two' -> '2'.
	third := {'name' -> 'Foo'. 'mail' -> 'bar@baz.com'}.
	strm nextPut: first.
	strm nextPut: second.
	strm nextPutAssociations: third.
	self assert: strm length equals: 3.
	conts := strm contents.
	self assert: conts size equals: 3.
	self assert: conts first content equals: first.
	self assert: conts second content equals: second.
	self assert: conts third contents equals: third.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	conts := strm contents.
	self assert: conts size equals: 0.