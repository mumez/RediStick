Class {
	#name : 'RsTsMRangeTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsMRangeTest >> testTsMRangeBasicReturnsRangeValues [
	| key1 key2 result |
	key1 := 'test:ts:mrange:basic:1'.
	key2 := 'test:ts:mrange:basic:2'.
	stick endpoint tsCreate: key1 using: [ :opts | opts labels: { 'type' -> 'mrange' } ].
	stick endpoint tsCreate: key2 using: [ :opts | opts labels: { 'type' -> 'mrange' } ].
	stick endpoint tsAdd: key1 timestamp: 1000 value: 10.
	stick endpoint tsAdd: key1 timestamp: 2000 value: 20.
	stick endpoint tsAdd: key2 timestamp: 1000 value: 30.
	stick endpoint tsAdd: key2 timestamp: 2000 value: 40.

	result := stick endpoint
		tsMRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrange' ].

	self assert: result size equals: 2.
	result do: [ :rv |
		self assert: rv isRsTsRangeValue.
		self assert: rv values size equals: 2 ]
]

{ #category : 'tests' }
RsTsMRangeTest >> testTsMRangeValueHasKeyAndValues [
	| key result rangeValue |
	key := 'test:ts:mrange:kv'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'mrkv' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 10.
	stick endpoint tsAdd: key timestamp: 2000 value: 20.

	result := stick endpoint
		tsMRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrkv' ].

	rangeValue := result first.
	self assert: rangeValue key equals: key.
	self assert: rangeValue values size equals: 2.
	self assert: rangeValue values first value equals: 10.
	self assert: rangeValue values second value equals: 20
]

{ #category : 'tests' }
RsTsMRangeTest >> testTsMRangeWithAggregation [
	| key result rangeValue |
	key := 'test:ts:mrange:agg'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'mragg' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 10.
	stick endpoint tsAdd: key timestamp: 1500 value: 20.
	stick endpoint tsAdd: key timestamp: 2000 value: 30.

	result := stick endpoint
		tsMRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mragg' ]
		aggregationBy: [ :agg | agg sum; bucketDuration: 1000 ]
		using: nil.

	rangeValue := result first.
	self assert: rangeValue isRsTsRangeValue.
	self assert: rangeValue values size equals: 2
]

{ #category : 'tests' }
RsTsMRangeTest >> testTsMRangeWithGroupBy [
	| key1 key2 result groupedValue |
	key1 := 'test:ts:mrange:group:1'.
	key2 := 'test:ts:mrange:group:2'.
	stick endpoint tsCreate: key1 using: [ :opts | opts labels: { 'type' -> 'mrgroup'. 'region' -> 'east' } ].
	stick endpoint tsCreate: key2 using: [ :opts | opts labels: { 'type' -> 'mrgroup'. 'region' -> 'east' } ].
	stick endpoint tsAdd: key1 timestamp: 1000 value: 10.
	stick endpoint tsAdd: key2 timestamp: 1000 value: 20.

	result := stick endpoint
		tsMRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrgroup' ]
		aggregationBy: [ :agg | agg sum; bucketDuration: 1000 ]
		groupBy: [ :g | g label: 'region'; reduce: 'sum' ]
		using: nil.

	self assert: result size equals: 1.
	groupedValue := result first.
	self assert: groupedValue isRsTsGroupedRangeValue.
	self assert: groupedValue groupByLabel key equals: 'region'.
	self assert: groupedValue groupByLabel value equals: 'east'.
	self assert: groupedValue reducer equals: 'sum'.
	self assert: groupedValue sourceKeys size equals: 2
]

{ #category : 'tests' }
RsTsMRangeTest >> testTsMRangeWithoutFiltersSignalsError [
	self should: [
		stick endpoint
			tsMRangeBy: [ :r | r all ]
			filterBy: [ :f | ]
	] raise: Error
]

{ #category : 'tests' }
RsTsMRangeTest >> testTsMRangeNoMatchingSeriesReturnsEmptyArray [
	self assertCollection: (stick endpoint
		tsMRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'test:ts:mrange:nomatch' ])
	equals: #()
]
