Class {
	#name : 'RsTsCreateOptions',
	#superclass : 'RsTsSchemaOptions',
	#instVars : [
		'ignoreMaxTimediff',
		'ignoreMaxValDiff'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsCreateOptions >> asArray [
	| opts |
	opts := super asArray asOrderedCollection.
	(self ignoreMaxTimediff notNil and: [ self ignoreMaxValDiff notNil ]) ifTrue: [
		opts addAll: { 'IGNORE'. self ignoreMaxTimediff. self ignoreMaxValDiff } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsCreateOptions >> ignoreMaxTimediff [
	^ ignoreMaxTimediff
]

{ #category : 'accessing' }
RsTsCreateOptions >> ignoreMaxTimediff: anInteger [
	ignoreMaxTimediff := anInteger
]

{ #category : 'accessing' }
RsTsCreateOptions >> ignoreMaxValDiff [
	^ ignoreMaxValDiff
]

{ #category : 'accessing' }
RsTsCreateOptions >> ignoreMaxValDiff: aNumber [
	ignoreMaxValDiff := aNumber
]
