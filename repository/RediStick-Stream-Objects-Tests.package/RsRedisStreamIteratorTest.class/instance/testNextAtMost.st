tests
testNextAtMost
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testNextAtMost'.
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
	ite1 nextAtMost: 2 do: [ :each | entries1 add: each ].
	self assert: entries1 size equals: 2.
	self assert: entries1 first content equals: two.
	self assert: entries1 second content equals: three.
	ite2 := strm iteratorNextFrom: entries1 second.
	entries2 := OrderedCollection new.
	ite2 nextAtMost: 5 do: [ :each | entries2 add: each ].
	self assert: entries2 size equals: 2.
	self assert: entries2 first content equals: four.
	self assert: entries2 last content equals: five.
	strm trimTo: 0.
	self assert: strm length equals: 0.