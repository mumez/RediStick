Class {
	#name : 'RsTsMRevRangeTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsMRevRangeTest >> testTsMRevRangeReturnsDescendingTimestamps [
	"TS.MREVRANGE must return samples newest-first, opposite of TS.MRANGE"
	| key result timestamps |
	key := 'test:ts:mrevrange:order'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'mrevorder' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 10.
	stick endpoint tsAdd: key timestamp: 2000 value: 20.
	stick endpoint tsAdd: key timestamp: 3000 value: 30.

	result := stick endpoint
		tsMRevRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrevorder' ].

	self assert: result size equals: 1.
	timestamps := result first values collect: [ :each | each key ].
	self assert: timestamps equals: #(3000 2000 1000)
]

{ #category : 'tests' }
RsTsMRevRangeTest >> testTsMRevRangeOppositeOfMRange [
	"The timestamp order of MREVRANGE must be the reverse of MRANGE for the same data"
	| key mrangeResult mrevResult |
	key := 'test:ts:mrevrange:vs:mrange'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'mrevvsmr' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 10.
	stick endpoint tsAdd: key timestamp: 2000 value: 20.
	stick endpoint tsAdd: key timestamp: 3000 value: 30.

	mrangeResult := (stick endpoint
		tsMRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrevvsmr' ]) first values.

	mrevResult := (stick endpoint
		tsMRevRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrevvsmr' ]) first values.

	self
		assertCollection: (mrangeResult collect: [ :e | e key ])
		equals: #(1000 2000 3000).
	self
		assertCollection: (mrevResult collect: [ :e | e key ])
		equals: #(3000 2000 1000)
]

{ #category : 'tests' }
RsTsMRevRangeTest >> testTsMRevRangeWithoutFiltersSignalsError [
	self should: [
		stick endpoint
			tsMRevRangeBy: [ :r | r all ]
			filterBy: [ :f | ]
	] raise: Error
]

{ #category : 'tests' }
RsTsMRevRangeTest >> testTsMRevRangeReturnsRangeValueInstances [
	| key result |
	key := 'test:ts:mrevrange:type'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'mrevtype' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 42.

	result := stick endpoint
		tsMRevRangeBy: [ :r | r all ]
		filterBy: [ :f | f label: 'type' eq: 'mrevtype' ].

	self assert: result size equals: 1.
	self assert: result first isRsTsRangeValue
]
