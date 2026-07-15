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

{ #category : 'accessing' }
RsTsAggregation >> aggregators [
	^ aggregators
]

{ #category : 'aggregators' }
RsTsAggregation >> avg [
	self aggregators add: 'avg'
]

{ #category : 'accessing' }
RsTsAggregation >> bucketDuration [
	^ bucketDuration
]

{ #category : 'accessing' }
RsTsAggregation >> bucketDuration: anInteger [
	bucketDuration := anInteger
]

{ #category : 'aggregators' }
RsTsAggregation >> count [
	self aggregators add: 'count'
]

{ #category : 'aggregators' }
RsTsAggregation >> countAll [
	"Requires Redis TimeSeries 8.6+"
	self aggregators add: 'countAll'
]

{ #category : 'aggregators' }
RsTsAggregation >> countNaN [
	"Requires Redis TimeSeries 8.6+"
	self aggregators add: 'countNaN'
]

{ #category : 'aggregators' }
RsTsAggregation >> first [
	self aggregators add: 'first'
]

{ #category : 'aggregators' }
RsTsAggregation >> last [
	self aggregators add: 'last'
]

{ #category : 'aggregators' }
RsTsAggregation >> max [
	self aggregators add: 'max'
]

{ #category : 'aggregators' }
RsTsAggregation >> min [
	self aggregators add: 'min'
]

{ #category : 'aggregators' }
RsTsAggregation >> range [
	self aggregators add: 'range'
]

{ #category : 'aggregators' }
RsTsAggregation >> stdP [
	self aggregators add: 'std.p'
]

{ #category : 'aggregators' }
RsTsAggregation >> stdS [
	self aggregators add: 'std.s'
]

{ #category : 'aggregators' }
RsTsAggregation >> sum [
	self aggregators add: 'sum'
]

{ #category : 'aggregators' }
RsTsAggregation >> twa [
	self aggregators add: 'twa'
]

{ #category : 'aggregators' }
RsTsAggregation >> varP [
	self aggregators add: 'var.p'
]

{ #category : 'aggregators' }
RsTsAggregation >> varS [
	self aggregators add: 'var.s'
]

{ #category : 'converting' }
RsTsAggregation >> asArray [
	self aggregators isEmpty ifTrue: [ Error signal: 'At least one aggregator must be selected' ].
	self bucketDuration ifNil: [ Error signal: 'bucketDuration must be set' ].
	^ { 'AGGREGATION'. (self aggregators fold: [ :a :b | a , ',' , b ]). self bucketDuration }
]
