Class {
	#name : 'RsTsNAggregationTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsNAggregationTest >> testForKeyBuildsSingleAggregatorList [
	| nAgg |
	nAgg := RsTsNAggregation new.
	nAgg forKey: [ :agg | agg avg ].
	self assert: nAgg perKeyAggregators size equals: 1.
	self assert: nAgg perKeyAggregators first aggregatorsString equals: 'avg'
]

{ #category : 'tests' }
RsTsNAggregationTest >> testForKeyBuildsMultiAggregatorList [
	| nAgg |
	nAgg := RsTsNAggregation new.
	nAgg forKey: [ :agg | agg avg; max ].
	self assert: nAgg perKeyAggregators size equals: 1.
	self assert: nAgg perKeyAggregators first aggregatorsString equals: 'avg,max'
]

{ #category : 'tests' }
RsTsNAggregationTest >> testAsArrayShapeAndOrdering [
	| nAgg |
	nAgg := RsTsNAggregation new.
	nAgg forKey: [ :agg | agg avg ].
	nAgg forKey: [ :agg | agg min; max ].
	nAgg bucketDuration: 1000.
	self assertCollection: nAgg asArray equals: { 'AGGREGATION'. 'avg'. 'min,max'. 1000 }
]

{ #category : 'tests' }
RsTsNAggregationTest >> testAsArrayWithoutPerKeyAggregatorsSignalsError [
	| nAgg |
	nAgg := RsTsNAggregation new.
	nAgg bucketDuration: 1000.
	self should: [ nAgg asArray ] raise: Error
]

{ #category : 'tests' }
RsTsNAggregationTest >> testAsArrayWithoutBucketDurationSignalsError [
	| nAgg |
	nAgg := RsTsNAggregation new.
	nAgg forKey: [ :agg | agg avg ].
	self should: [ nAgg asArray ] raise: Error
]
