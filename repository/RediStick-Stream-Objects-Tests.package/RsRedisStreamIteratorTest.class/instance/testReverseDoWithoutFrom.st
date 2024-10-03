tests
testReverseDoWithoutFrom
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testReverseDoWithoutFrom'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	ite1 := strm reverseIterator.
	entries1 := OrderedCollection new.
	ite1 do: [ :each | entries1 add: each ].
	self assert: entries1 size equals: 5.
	self assert: entries1 first content equals: five.
	self assert: entries1 second content equals: four.
	self assert: entries1 last content equals: one.
	ite2 := strm reverseIterator.
	entries2 := ite2 collect: [ :each | each ].
	self assert: entries2 size equals: 5.
	self assert: entries2 first content equals: five.
	self assert: entries2 last content equals: one.
	strm trimTo: 0.
	self assert: strm length equals: 0.