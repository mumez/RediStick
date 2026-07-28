Class {
	#name : 'RsTsAggregationOptions',
	#superclass : 'Object',
	#instVars : [
		'align',
		'bucketTimestamp',
		'empty',
		'aggregation'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsAggregationOptions >> initialize [
	super initialize.
	empty := false
]

{ #category : 'accessing' }
RsTsAggregationOptions >> aggregation [
	^ aggregation
]

{ #category : 'accessing' }
RsTsAggregationOptions >> aggregation: anAggregation [
	aggregation := anAggregation
]

{ #category : 'accessing' }
RsTsAggregationOptions >> align [
	^ align
]

{ #category : 'accessing' }
RsTsAggregationOptions >> align: aValue [
	align := RsTsRange normalizeTimestamp: aValue
]

{ #category : 'accessing' }
RsTsAggregationOptions >> bucketTimestamp [
	^ bucketTimestamp
]

{ #category : 'accessing' }
RsTsAggregationOptions >> bucketTimestamp: aToken [
	bucketTimestamp := aToken
]

{ #category : 'accessing' }
RsTsAggregationOptions >> empty [
	empty := true
]

{ #category : 'accessing' }
RsTsAggregationOptions >> isEmpty [
	^ empty
]

{ #category : 'converting' }
RsTsAggregationOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	self align ifNotNil: [ :a | opts addAll: { 'ALIGN'. a } ].
	self aggregation ifNotNil: [ opts addAll: self aggregation asArray ].
	self bucketTimestamp ifNotNil: [ :bt | opts addAll: { 'BUCKETTIMESTAMP'. bt } ].
	self isEmpty ifTrue: [ opts add: 'EMPTY' ].
	^ opts asArray
]
