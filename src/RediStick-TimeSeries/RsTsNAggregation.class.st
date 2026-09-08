"
I build the per-key AGGREGATION clause for TS.NRANGE/TS.NREVRANGE.

Responsibility:
- I hold one RsTsAggregation per key, in key order, added via #forKey:.
- I hold a single bucketDuration shared by all keys.
- I convert myself into the AGGREGATION command tokens via #asArray.

Collaborators:
- RsTsAggregation: each per-key entry is a plain RsTsAggregation. Unlike TS.RANGE/TS.MRANGE (one aggregator list for the whole command), TS.NRANGE allows a comma-joined multi-aggregator list per key, so #asArray calls #aggregatorsString on each entry to bypass RsTsAggregation's single-aggregator check.
- RsTsAggregationOptions: wraps me for ALIGN/BUCKETTIMESTAMP/EMPTY, via its #aggregation: setter.

Public API and Key Messages:
- #forKey: aBlock - creates a new RsTsAggregation, evaluates aBlock with it, appends it in key order, and answers it.
- #bucketDuration: - sets the shared bucket duration.
- #asArray - answers the AGGREGATION command tokens; signals Error if no per-key aggregation or no bucketDuration was provided.
"
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
