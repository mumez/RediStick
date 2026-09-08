Class {
	#name : 'RsTsNRangeTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsNRangeTest >> testTsNRangeBasicGroupsByTimestamp [
	| key1 key2 result |
	key1 := 'test:ts:nrange:basic:1'.
	key2 := 'test:ts:nrange:basic:2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	stick endpoint tsAdd: key1 timestamp: 1000 value: 10.
	stick endpoint tsAdd: key2 timestamp: 1000 value: 20.
	stick endpoint tsAdd: key1 timestamp: 2000 value: 30.

	result := stick endpoint
		tsNRangeBy: [ :r | r all ]
		keys: { key1. key2 }.

	self assert: result size equals: 2.
	self assert: (result first isRsTsNRangeRow).
	self assert: result first timestamp equals: 1000.
	self assert: result first values size equals: 2.
	self assert: result first values first equals: 10.
	self assert: result first values second equals: 20.

	self assert: result second timestamp equals: 2000.
	self assert: result second values size equals: 2.
	self assert: result second values first equals: 30
]

{ #category : 'tests' }
RsTsNRangeTest >> testTsNRangeWithAggregationPerKey [
	| key1 key2 result |
	key1 := 'test:ts:nrange:agg:1'.
	key2 := 'test:ts:nrange:agg:2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	stick endpoint tsAdd: key1 timestamp: 1000 value: 10.
	stick endpoint tsAdd: key1 timestamp: 1500 value: 20.
	stick endpoint tsAdd: key2 timestamp: 1000 value: 100.
	stick endpoint tsAdd: key2 timestamp: 1500 value: 200.

	result := stick endpoint
		tsNRangeBy: [ :r | r all ]
		keys: { key1. key2 }
		aggregationBy: [ :nAgg :opts |
			nAgg forKey: [ :agg | agg avg ].
			nAgg forKey: [ :agg | agg min; max ].
			nAgg bucketDuration: 1000 ].

	self assert: result notEmpty.
	self assert: result first values size equals: 3
]

{ #category : 'tests' }
RsTsNRangeTest >> testTsNRangeWithoutKeysSignalsError [
	self should: [
		stick endpoint tsNRangeBy: [ :r | r all ] keys: #()
	] raise: Error
]

{ #category : 'tests' }
RsTsNRangeTest >> testTsNRangeNoMatchingSeriesReturnsEmptyArray [
	self assertCollection: (stick endpoint
		tsNRangeBy: [ :r | r all ]
		keys: { 'test:ts:nrange:nomatch' })
	equals: #()
]
