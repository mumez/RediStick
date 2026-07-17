Class {
	#name : 'RsTsCreateOptions',
	#superclass : 'RsTsOptions',
	#instVars : [
		'duplicatePolicy',
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
	self duplicatePolicy ifNotNil: [ :op | opts addAll: { 'DUPLICATE_POLICY'. op } ].
	(self ignoreMaxTimediff notNil and: [ self ignoreMaxValDiff notNil ]) ifTrue: [
		opts addAll: { 'IGNORE'. self ignoreMaxTimediff. self ignoreMaxValDiff } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsCreateOptions >> duplicatePolicy [

	^ duplicatePolicy
]

{ #category : 'accessing' }
RsTsCreateOptions >> duplicatePolicy: anObject [

	duplicatePolicy := anObject
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
