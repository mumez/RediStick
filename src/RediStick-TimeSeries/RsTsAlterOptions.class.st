Class {
	#name : 'RsTsAlterOptions',
	#superclass : 'RsTsOptions',
	#instVars : [
		'duplicatePolicy'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsAlterOptions >> asArray [
	| opts |
	opts := super asArray asOrderedCollection.
	self duplicatePolicy ifNotNil: [ :op | opts addAll: { 'DUPLICATE_POLICY'. op } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsAlterOptions >> encoding: anObject [
	"TS.ALTER does not support ENCODING — ignored"
]

{ #category : 'accessing' }
RsTsAlterOptions >> duplicatePolicy [

	^ duplicatePolicy
]

{ #category : 'accessing' }
RsTsAlterOptions >> duplicatePolicy: anObject [

	duplicatePolicy := anObject
]
