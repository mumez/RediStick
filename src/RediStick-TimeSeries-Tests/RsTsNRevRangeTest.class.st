Class {
	#name : 'RsTsNRevRangeTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'helpers' }
RsTsNRevRangeTest >> addThreeSamplesTo: key1 and: key2 [
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	stick endpoint tsAdd: key1 timestamp: 1000 value: 10.
	stick endpoint tsAdd: key2 timestamp: 1000 value: 20.
	stick endpoint tsAdd: key1 timestamp: 2000 value: 30.
	stick endpoint tsAdd: key2 timestamp: 2000 value: 40.
	stick endpoint tsAdd: key1 timestamp: 3000 value: 50.
	stick endpoint tsAdd: key2 timestamp: 3000 value: 60
]

{ #category : 'tests' }
RsTsNRevRangeTest >> testTsNRevRangeReturnsDescendingTimestamps [
	"TS.NREVRANGE must return rows newest-first, opposite of TS.NRANGE"
	| key1 key2 result timestamps |
	key1 := 'test:ts:nrevrange:order:1'.
	key2 := 'test:ts:nrevrange:order:2'.
	self addThreeSamplesTo: key1 and: key2.

	result := stick endpoint
		tsNRevRangeBy: [ :r | r all ]
		keys: { key1. key2 }.

	self assert: result size equals: 3.
	timestamps := result collect: [ :row | row timestamp ].
	self assertCollection: timestamps equals: #(3000 2000 1000)
]

{ #category : 'tests' }
RsTsNRevRangeTest >> testTsNRevRangeOppositeOfNRange [
	"The timestamp order of NREVRANGE must be the reverse of NRANGE for the same data"
	| key1 key2 nRangeResult nRevRangeResult |
	key1 := 'test:ts:nrevrange:vs:nrange:1'.
	key2 := 'test:ts:nrevrange:vs:nrange:2'.
	self addThreeSamplesTo: key1 and: key2.

	nRangeResult := stick endpoint
		tsNRangeBy: [ :r | r all ]
		keys: { key1. key2 }.
	nRevRangeResult := stick endpoint
		tsNRevRangeBy: [ :r | r all ]
		keys: { key1. key2 }.

	self
		assertCollection: (nRangeResult collect: [ :row | row timestamp ])
		equals: #(1000 2000 3000).
	self
		assertCollection: (nRevRangeResult collect: [ :row | row timestamp ])
		equals: #(3000 2000 1000)
]

{ #category : 'tests' }
RsTsNRevRangeTest >> testTsNRevRangeWithoutKeysSignalsError [
	self should: [
		stick endpoint tsNRevRangeBy: [ :r | r all ] keys: #()
	] raise: Error
]
