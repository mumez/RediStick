Class {
	#name : 'RsTsRangeOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsRangeOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsTsRangeOptions new asArray equals: #()
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testLatestFlag [
	| opts |
	opts := RsTsRangeOptions new.
	opts latest.
	self assertCollection: opts asArray equals: { 'LATEST' }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testFilterByTs [
	| opts |
	opts := RsTsRangeOptions new.
	opts filterByTs: { 1000. 2000 }.
	self assertCollection: opts asArray equals: { 'FILTER_BY_TS'. 1000. 2000 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testFilterByValue [
	| opts |
	opts := RsTsRangeOptions new.
	opts filterByValueMin: -100 max: 100.
	self assertCollection: opts asArray equals: { 'FILTER_BY_VALUE'. -100. 100 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testCount [
	| opts |
	opts := RsTsRangeOptions new.
	opts count: 10.
	self assertCollection: opts asArray equals: { 'COUNT'. 10 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testAllOptionsCombinedInRedisOrder [
	| opts |
	opts := RsTsRangeOptions new.
	opts
		latest;
		filterByTs: { 1000 };
		filterByValueMin: -100 max: 100;
		count: 10.
	self assertCollection: opts asArray
		equals: { 'LATEST'. 'FILTER_BY_TS'. 1000. 'FILTER_BY_VALUE'. -100. 100. 'COUNT'. 10 }
]

{ #category : 'tests' }
RsTsRangeOptionsTest >> testFilterByTsNormalizesDateAndTime [
	| opts now |
	now := DateAndTime now.
	opts := RsTsRangeOptions new.
	opts filterByTs: { now }.
	self assertCollection: opts asArray equals: { 'FILTER_BY_TS'. now asRediStickUnixTimestampMillis }
]
