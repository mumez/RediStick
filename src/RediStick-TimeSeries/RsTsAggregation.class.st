Class {
	#name : 'RsTsAggregation',
	#superclass : 'Object',
	#instVars : [
		'aggregators',
		'bucketDuration',
		'isSingleAggregator'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsAggregation class >> forSingle [
	^ self new isSingleAggregator: true; yourself.
]

{ #category : 'initialization' }
RsTsAggregation >> initialize [
	super initialize.
	aggregators := OrderedCollection new.
	isSingleAggregator := false
]

{ #category : 'accessing' }
RsTsAggregation >> aggregators [
	^ aggregators
]

{ #category : 'private-accessing' }
RsTsAggregation >> isSingleAggregator [
	^ isSingleAggregator
]

{ #category : 'private-accessing' }
RsTsAggregation >> isSingleAggregator: aBoolean [
	isSingleAggregator := aBoolean
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
	self aggregators ifEmpty: [ Error signal: 'At least one aggregator must be selected' ].
	self bucketDuration ifNil: [ Error signal: 'bucketDuration must be set' ].
	(self isSingleAggregator and: [ self aggregators size > 1 ])
		ifTrue: [ Error signal: 'Only one aggregator is allowed in this context' ].
	^ { 'AGGREGATION'. ($, join: self aggregators). self bucketDuration }
]
