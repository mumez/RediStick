Class {
	#name : 'RsRedisStreamTest',
	#superclass : 'RsRedisStreamBaseTestCase',
	#category : 'RediStick-Stream-Objects-Tests',
	#package : 'RediStick-Stream-Objects-Tests'
}

{ #category : 'tests' }
RsRedisStreamTest >> testComing [
	| strm strm2 nextComing nextThree |
	strm := self newStreamNamed: 'testComing'.
	strm2 := self newStreamNamed: 'testComing'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	strm2 nextPut: 0 -> 0.
	[
	(Delay forMilliseconds: 10) wait.
	1 to: 10 do: [ :idx |
		strm2 nextPut: idx -> idx.
		(Delay forMilliseconds: 50) wait ] ] fork.

	nextComing := strm comingAtMost: 3 waitFor: 200.
	self assert: nextComing size equals: 1.
	self assert: nextComing first content equals: '1' -> '1'.

	(Delay forMilliseconds: 300) wait.
	nextThree := strm
		             nextAtMost: 3
		             after: nextComing first id
		             waitFor: 500.
	self assert: nextThree size equals: 3.
	self assert: nextThree first content equals: '2' -> '2'.
	self assert: nextThree second content equals: '3' -> '3'.
	self assert: nextThree third content equals: '4' -> '4'.
	self assert: strm length >= 5.
	strm trimTo: 0.
	self assert: strm length equals: 0
]

{ #category : 'tests' }
RsRedisStreamTest >> testContentsFrom [
	| strm conts fifteen fifteenToLast seventeen fifteenToSeventeen eighteenToLast |
	strm := self newStreamNamed: 'testContentsFrom'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	1 to: 20 do: [ :idx |
		strm nextPut: idx -> idx.
	].
	conts := strm contents.
	self assert: conts size equals: 20.
	fifteen := conts at: 15.
	fifteenToLast := strm contentsFrom: fifteen id.
	
	self assert: fifteenToLast size equals: 6.
	self assert: conts last content equals: fifteenToLast last content.
	
	seventeen := conts at: 17.
	fifteenToSeventeen := strm contentsFrom: fifteen id to: seventeen id.
	
	self assert: fifteenToSeventeen size equals: 3.
	self assert: fifteenToLast first content equals: fifteenToSeventeen first content.
	
	self assert: (strm contentAt: seventeen id) content equals: '17'->'17'.
	
	eighteenToLast := strm contentsNextFrom: seventeen id count: 3.
	self assert: eighteenToLast size equals: 3.
	self assert: conts last content equals: eighteenToLast last content.
	
	strm trimTo: 0.
	self assert: strm length equals: 0
]

{ #category : 'tests' }
RsRedisStreamTest >> testContentsReversedFrom [
	| strm conts fifteen fifteenToFirst seventeen seventeenToFifteen sixteenToFifteen |
	strm := self newStreamNamed: 'testContentsReversedFrom'.
	strm trimTo: 0.
	self assert: strm length equals: 0.
	1 to: 20 do: [ :idx |
		strm nextPut: idx -> idx.
	].
	conts := strm contentsReversed.
	self assert: conts size equals: 20.
	fifteen := conts at: 6.
	fifteenToFirst := strm contentsReversedFrom: fifteen id.
	
	self assert: fifteenToFirst size equals: 15.
	self assert: conts last content equals: fifteenToFirst last content.
	
	seventeen := conts at: 4.
	seventeenToFifteen := strm contentsReversedFrom: seventeen id to: fifteen id.
	
	self assert: seventeenToFifteen size equals: 3.
	self assert: fifteenToFirst first content equals: seventeenToFifteen last content.
	
	self assert: (strm contentAt: seventeen id) content equals: '17'->'17'.
	
	sixteenToFifteen := strm contentsReversedNextFrom: seventeen id count: 2.
	self assert: sixteenToFifteen size equals: 2.
	self assert: fifteenToFirst first content equals: sixteenToFifteen last content.
	
	strm trimTo: 0.
	self assert: strm length equals: 0
]

{ #category : 'tests' }
RsRedisStreamTest >> testDelete [
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
]

{ #category : 'tests' }
RsRedisStreamTest >> testDeletes [
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
]

{ #category : 'tests' }
RsRedisStreamTest >> testFirstLast [
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
]

{ #category : 'tests' }
RsRedisStreamTest >> testNextPutWithMessageId [
	| strm one two three four five invalidId conts |
	strm := self newStreamNamed: 'testNextPutWithMessageId'.
	strm beEmptyAndReset.
	self assert: strm length equals: 0.
	one := 'one' -> '1'.
	two := 'two' -> '2'.
	three := 'three' -> '3'.
	four := 'four' -> '4'.
	five := 'five' -> '5'.
	invalidId := RsStreamMessageId epoch.
	self assert: (strm nextPut: one at: invalidId) equals: nil.
	self assert: strm length equals: 0.
	
	strm nextPut: one at: '0-1'.
	strm nextPut: two at: (RsStreamMessageId mainId: 0 subId: 2).
	conts := strm contents.
	self assert: strm length equals: 2.
	self assert: conts first content equals: one.
	self assert: conts second content equals: two.
	
	strm nextPut: three at: (RsStreamMessageId mainIdOnly: 1).
	strm nextPut: four at: (RsStreamMessageId mainIdSubIncremented: 1).
	self assert: (strm nextPut: five at: (RsStreamMessageId mainIdOnly: 1)) equals: nil.
	conts := strm contents.
	self assert: strm length equals: 4.
	self assert: conts first content equals: one.
	self assert: conts last content equals: four.
	self assert: (conts collect: [ :each | each id ]) asArray equals: #('0-1' '0-2' '1-0' '1-1').
	self assert: strm info lastGeneratedId equals: '1-1'.
	
	strm trimLowerThan: (RsStreamMessageId mainId: 1 subId: 0).
	conts := strm contents.
	self assert: strm length equals: 2.
	self assert: conts first content equals: three.
	self assert: conts last content equals: four.
	
	strm trimTo: 0.
	self assert: strm length equals: 0
]
