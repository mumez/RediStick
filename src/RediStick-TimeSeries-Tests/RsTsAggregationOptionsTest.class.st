Class {
	#name : 'RsTsAggregationOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'helpers' }
RsTsAggregationOptionsTest >> avgAggregation [
	| agg |
	agg := RsTsAggregation new.
	agg avg; bucketDuration: 1000.
	^ agg
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAggregationOnly [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignWithInteger [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; align: 10.
	self assertCollection: opts asArray equals: { 'ALIGN'. 10. 'AGGREGATION'. 'avg'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignWithSentinelString [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; align: '-'.
	self assertCollection: opts asArray equals: { 'ALIGN'. '-'. 'AGGREGATION'. 'avg'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestamp [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; bucketTimestamp: '+'.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000. 'BUCKETTIMESTAMP'. '+' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testEmptyFlag [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; empty.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000. 'EMPTY' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestampAndEmptyCombinedInOrder [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; bucketTimestamp: '~'; empty.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000. 'BUCKETTIMESTAMP'. '~'. 'EMPTY' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAllOptionsInOrder [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; align: '-'; bucketTimestamp: '~'; empty.
	self assertCollection: opts asArray
		equals: { 'ALIGN'. '-'. 'AGGREGATION'. 'avg'. 1000. 'BUCKETTIMESTAMP'. '~'. 'EMPTY' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignStart [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; alignStart.
	self assertCollection: opts asArray equals: { 'ALIGN'. '-'. 'AGGREGATION'. 'avg'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignEnd [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; alignEnd.
	self assertCollection: opts asArray equals: { 'ALIGN'. '+'. 'AGGREGATION'. 'avg'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestampStart [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; bucketTimestampStart.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000. 'BUCKETTIMESTAMP'. '-' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestampEnd [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; bucketTimestampEnd.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000. 'BUCKETTIMESTAMP'. '+' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestampMid [
	| opts |
	opts := RsTsAggregationOptions new.
	opts aggregation: self avgAggregation; bucketTimestampMid.
	self assertCollection: opts asArray equals: { 'AGGREGATION'. 'avg'. 1000. 'BUCKETTIMESTAMP'. '~' }
]
