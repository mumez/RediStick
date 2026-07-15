Class {
	#name : 'RsTsAggregation',
	#superclass : 'Object',
	#instVars : [
		'aggregators',
		'bucketDuration'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsAggregation >> initialize [
	super initialize.
	aggregators := OrderedCollection new
]

{ #category : 'aggregators' }
RsTsAggregation >> avg [
	aggregators add: 'avg'
]

{ #category : 'accessing' }
RsTsAggregation >> bucketDuration: anInteger [
	bucketDuration := anInteger
]

{ #category : 'aggregators' }
RsTsAggregation >> count [
	aggregators add: 'count'
]

{ #category : 'aggregators' }
RsTsAggregation >> countAll [
	"Requires Redis TimeSeries 8.6+"
	aggregators add: 'countAll'
]

{ #category : 'aggregators' }
RsTsAggregation >> countNaN [
	"Requires Redis TimeSeries 8.6+"
	aggregators add: 'countNaN'
]

{ #category : 'aggregators' }
RsTsAggregation >> first [
	aggregators add: 'first'
]

{ #category : 'aggregators' }
RsTsAggregation >> last [
	aggregators add: 'last'
]

{ #category : 'aggregators' }
RsTsAggregation >> max [
	aggregators add: 'max'
]

{ #category : 'aggregators' }
RsTsAggregation >> min [
	aggregators add: 'min'
]

{ #category : 'aggregators' }
RsTsAggregation >> range [
	aggregators add: 'range'
]

{ #category : 'aggregators' }
RsTsAggregation >> stdP [
	aggregators add: 'std.p'
]

{ #category : 'aggregators' }
RsTsAggregation >> stdS [
	aggregators add: 'std.s'
]

{ #category : 'aggregators' }
RsTsAggregation >> sum [
	aggregators add: 'sum'
]

{ #category : 'aggregators' }
RsTsAggregation >> twa [
	aggregators add: 'twa'
]

{ #category : 'aggregators' }
RsTsAggregation >> varP [
	aggregators add: 'var.p'
]

{ #category : 'aggregators' }
RsTsAggregation >> varS [
	aggregators add: 'var.s'
]

{ #category : 'converting' }
RsTsAggregation >> asArray [
	aggregators isEmpty ifTrue: [ Error signal: 'At least one aggregator must be selected' ].
	bucketDuration ifNil: [ Error signal: 'bucketDuration must be set' ].
	^ { 'AGGREGATION'. (aggregators fold: [ :a :b | a , ',' , b ]). bucketDuration }
]
