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

{ #category : 'converting' }
RsTsAggregationOptions >> alignArray [
	^ align ifNil: [ #() ] ifNotNil: [ { 'ALIGN'. align } ]
]

{ #category : 'accessing' }
RsTsAggregationOptions >> align: aValue [
	align := aValue isString ifTrue: [ aValue ] ifFalse: [ aValue asRediStickUnixTimestampMillis ]
]

{ #category : 'accessing' }
RsTsAggregationOptions >> bucketTimestamp: aToken [
	bucketTimestamp := aToken
]

{ #category : 'accessing' }
RsTsAggregationOptions >> empty [
	empty := true
]

{ #category : 'converting' }
RsTsAggregationOptions >> tailArray [
	| opts |
	opts := OrderedCollection new.
	bucketTimestamp ifNotNil: [ :bt | opts addAll: { 'BUCKETTIMESTAMP'. bt } ].
	empty ifTrue: [ opts add: 'EMPTY' ].
	^ opts asArray
]
