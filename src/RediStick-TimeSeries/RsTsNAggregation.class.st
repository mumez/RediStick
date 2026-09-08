Class {
	#name : 'RsTsNAggregation',
	#superclass : 'Object',
	#instVars : [
		'perKeyAggregators',
		'bucketDuration'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsNAggregation >> initialize [
	super initialize.
	perKeyAggregators := OrderedCollection new
]

{ #category : 'accessing' }
RsTsNAggregation >> perKeyAggregators [
	^ perKeyAggregators
]

{ #category : 'accessing' }
RsTsNAggregation >> bucketDuration [
	^ bucketDuration
]

{ #category : 'accessing' }
RsTsNAggregation >> bucketDuration: anInteger [
	bucketDuration := anInteger
]

{ #category : 'building' }
RsTsNAggregation >> forKey: aBlock [
	| aggregation |
	aggregation := RsTsAggregation new.
	aBlock value: aggregation.
	self perKeyAggregators add: aggregation.
	^ aggregation
]

{ #category : 'converting' }
RsTsNAggregation >> asArray [
	self perKeyAggregators ifEmpty: [ (RsError invalidArguments) signal: 'At least one key aggregation must be provided' ].
	self bucketDuration ifNil: [ (RsError invalidArguments) signal: 'bucketDuration must be set' ].
	^ { 'AGGREGATION' } , (self perKeyAggregators collect: [ :agg | agg aggregatorsString ]) , { self bucketDuration }
]
