Class {
	#name : 'RsTsAlterOptions',
	#superclass : 'RsTsCreateOptions',
	#instVars : [
		'ignoreMaxTimediff',
		'ignoreMaxValDiff'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsAlterOptions >> asArray [
	| opts |
	opts := super asArray asOrderedCollection.
	(self ignoreMaxTimediff notNil and: [ self ignoreMaxValDiff notNil ]) ifTrue: [
		opts addAll: { 'IGNORE'. self ignoreMaxTimediff. self ignoreMaxValDiff } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsAlterOptions >> ignoreMaxTimediff [

	^ ignoreMaxTimediff
]

{ #category : 'accessing' }
RsTsAlterOptions >> ignoreMaxTimediff: anInteger [

	ignoreMaxTimediff := anInteger
]

{ #category : 'accessing' }
RsTsAlterOptions >> ignoreMaxValDiff [

	^ ignoreMaxValDiff
]

{ #category : 'accessing' }
RsTsAlterOptions >> ignoreMaxValDiff: aNumber [

	ignoreMaxValDiff := aNumber
]
