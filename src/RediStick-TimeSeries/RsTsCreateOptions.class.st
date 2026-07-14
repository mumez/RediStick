Class {
	#name : 'RsTsCreateOptions',
	#superclass : 'RsTsOptions',
	#instVars : [
		'duplicatePolicy'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsCreateOptions >> asArray [
	| opts |
	opts := super asArray asOrderedCollection.
	self duplicatePolicy ifNotNil: [ :op | opts addAll: { 'DUPLICATE_POLICY'. op } ].
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
