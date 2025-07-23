Class {
	#name : 'RsRedisStreamIteratorTest',
	#superclass : 'RsRedisStreamBaseTestCase',
	#category : 'RediStick-Stream-Objects-Tests',
	#package : 'RediStick-Stream-Objects-Tests'
}

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testByDoWhileFalse [
	| strm ite1 entries |
	strm := self newStreamNamed: 'testByDoWhileFalse'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	(1 to: 100) doWithIndex: [ :each :idx | 
		strm nextPut: (idx  -> each).
	].
	ite1 := strm iterator.
	entries := OrderedCollection new.
	ite1 by: 5 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | ents size = 5].
	self assert: entries size equals: 4.
	self assert: entries last content equals: ('4'->'4').
	entries := OrderedCollection new.
	ite1 by: 10 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | ent content = ('10'->'10')].
	self assert: entries size equals: 5.
	self assert: entries last content equals: ('9'->'9').
	entries := OrderedCollection new.
	ite1 by: 1 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | entries size > 10 ].
	self assert: entries size equals: 11.
	self assert: entries last content equals: ('20'->'20').
	entries := OrderedCollection new.
	ite1 by: 50 do: [:ent | entries add: ent ] whileFalse: [:ents :ent | ents isEmpty ].
	self assert: entries size equals: 80.
	self assert: entries last id equals: ite1 currentId asString.
	self assert: strm last id equals: ite1 currentId asString.
	strm trimTo: 0.
	self assert: strm length equals: 0.
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testDoCollect [
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
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testDoWithoutFrom [
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testDoWithoutFrom'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	ite1 := strm iterator.
	entries1 := OrderedCollection new.
	ite1 do: [ :each | entries1 add: each ].
	self assert: entries1 size equals: 5.
	self assert: entries1 first content equals: one.
	self assert: entries1 second content equals: two.
	self assert: entries1 last content equals: five.
	ite2 := strm iterator.
	entries2 := ite2 collect: [ :each | each ].
	self assert: entries2 size equals: 5.
	self assert: entries2 first content equals: one.
	self assert: entries2 last content equals: five.
	strm trimTo: 0.
	self assert: strm length equals: 0.
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testNextAtMost [
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
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testReverseDoWithoutFrom [
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
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testReversedDoCollect [
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testReversedDoCollect'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	ite1 := strm iteratorNextFromLast reversed.
	self assert: strm last content equals: five.
	entries1 := OrderedCollection new.
	ite1 do: [ :each | entries1 add: each ].
	self assert: entries1 size equals: 4.
	self assert: entries1 first content equals: four.
	self assert: entries1 second content equals: three.
	self assert: entries1 last content equals: one.
	ite2 := (strm iteratorNextFrom: entries1 second) reversed.
	entries2 := ite2 collect: [ :each | each ].
	self assert: entries2 size equals: 2.
	self assert: entries2 first content equals: two.
	self assert: entries2 last content equals: one.
	strm trimTo: 0.
	self assert: strm length equals: 0.
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testReversedNextAtMost [
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testReversedNextAtMost'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	strm << one << two << three << four << five.
	ite1 := strm iteratorNextFromLast reversed.
	self assert: strm last content equals: five.
	entries1 := OrderedCollection new.
	ite1 nextAtMost: 2 do: [ :each | entries1 add: each ].
	self assert: entries1 size equals: 2.
	self assert: entries1 first content equals: four.
	self assert: entries1 second content equals: three.
	ite2 := (strm iteratorNextFrom: entries1 second) reversed.
	entries2 := OrderedCollection new.
	ite2 nextAtMost: 5 do: [ :each | entries2 add: each ].
	self assert: entries2 size equals: 2.
	self assert: entries2 first content equals: two.
	self assert: entries2 last content equals: one.
	strm trimTo: 0.
	self assert: strm length equals: 0.
]

{ #category : 'tests' }
RsRedisStreamIteratorTest >> testSimplePoll [
	| strm one two three four five ite1 entries1 ite2 entries2 |
	strm := self newStreamNamed: 'testSimplePoll'.
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
]
