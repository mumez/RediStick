Class {
	#name : 'RsTsAggregationOptions',
	#superclass : 'Object',
	#instVars : [
		'align',
		'bucketTimestamp',
		'empty'
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
RsTsAggregationOptions >> align [
	^ align
]

{ #category : 'converting' }
RsTsAggregationOptions >> alignArray [
	^ self align ifNil: [ #() ] ifNotNil: [ { 'ALIGN'. self align } ]
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
RsTsAggregationOptions >> tailArray [
	| opts |
	opts := OrderedCollection new.
	self bucketTimestamp ifNotNil: [ :bt | opts addAll: { 'BUCKETTIMESTAMP'. bt } ].
	self isEmpty ifTrue: [ opts add: 'EMPTY' ].
	^ opts asArray
]
