tests
testDoCollect
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testDoCollect'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	ite1 := strm iteratorNextFromFirst.
	self assert: strm first content equals: one.
	entries1 := OrderedCollection new.
	ite1 do: [ :each | entries1 add: each ].
	self assert: entries1 size equals: 4.
	self assert: entries1 first content equals: two.
	self assert: entries1 second content equals: three.
	self assert: entries1 last content equals: five.
	ite2 := strm iteratorNextFrom: entries1 second.
	entries2 := ite2 collect: [ :each | each ].
	self assert: entries2 size equals: 2.
	self assert: entries2 first content equals: four.
	self assert: entries2 last content equals: five.
	strm trimTo: 0.
	self assert: strm length equals: 0.