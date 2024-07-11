tests
testFirstLast
	| strm one two three four five conts last |
	strm := self newStreamNamed: 'testFirstLast'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	conts := strm contents.
	self assert: conts size equals: 5.
	conts := strm first: 2.
	self assert: conts size equals: 2.
	self assert: conts first content equals: one.
	self assert: conts second content equals: two.
	conts := strm last: 3.
	self assert: conts size equals: 3.
	self assert: conts first content equals: three.
	self assert: conts second content equals: four.
	self assert: conts third content equals: five.
	last := strm last.
	self assert: last content equals: five.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	conts := strm contents.
	self assert: conts size equals: 0.