Class {
	#name : 'RsTsReadOptions',
	#superclass : 'Object',
	#instVars : [
		'blockMilliseconds',
		'blockMinCount',
		'maxCount'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsReadOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	(self blockMilliseconds notNil and: [ self blockMinCount notNil ]) ifTrue: [
		opts addAll: { 'BLOCK'. self blockMilliseconds. self blockMinCount } ].
	self maxCount ifNotNil: [ :c | opts addAll: { 'MAX_COUNT'. c } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsReadOptions >> block: milliseconds minCount: aMinCount [
	blockMilliseconds := milliseconds.
	blockMinCount := aMinCount
]

{ #category : 'accessing' }
RsTsReadOptions >> blockMilliseconds [
	^ blockMilliseconds
]

{ #category : 'accessing' }
RsTsReadOptions >> blockMinCount [
	^ blockMinCount
]

{ #category : 'accessing' }
RsTsReadOptions >> maxCount [
	^ maxCount
]

{ #category : 'accessing' }
RsTsReadOptions >> maxCount: anInteger [
	maxCount := anInteger
]
