Class {
	#name : 'RsTsAggregationOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testEmptyOptionsProduceEmptyArrays [
	| opts |
	opts := RsTsAggregationOptions new.
	self assertCollection: opts alignArray equals: #().
	self assertCollection: opts tailArray equals: #()
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignWithInteger [
	| opts |
	opts := RsTsAggregationOptions new.
	opts align: 10.
	self assertCollection: opts alignArray equals: { 'ALIGN'. 10 }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testAlignWithSentinelString [
	| opts |
	opts := RsTsAggregationOptions new.
	opts align: '-'.
	self assertCollection: opts alignArray equals: { 'ALIGN'. '-' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestamp [
	| opts |
	opts := RsTsAggregationOptions new.
	opts bucketTimestamp: '+'.
	self assertCollection: opts tailArray equals: { 'BUCKETTIMESTAMP'. '+' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testEmptyFlag [
	| opts |
	opts := RsTsAggregationOptions new.
	opts empty.
	self assertCollection: opts tailArray equals: { 'EMPTY' }
]

{ #category : 'tests' }
RsTsAggregationOptionsTest >> testBucketTimestampAndEmptyCombinedInOrder [
	| opts |
	opts := RsTsAggregationOptions new.
	opts bucketTimestamp: '~'; empty.
	self assertCollection: opts tailArray equals: { 'BUCKETTIMESTAMP'. '~'. 'EMPTY' }
]
