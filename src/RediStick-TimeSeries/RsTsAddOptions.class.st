Class {
	#name : 'RsTsAddOptions',
	#superclass : 'RsTsOptions',
	#instVars : [
		'onDuplicate'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'converting' }
RsTsAddOptions >> asArray [
	| opts |
	opts := super asArray asOrderedCollection.
	self onDuplicate ifNotNil: [ :op | opts addAll: { 'ON_DUPLICATE'. op } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsAddOptions >> onDuplicate [

	^ onDuplicate
]

{ #category : 'accessing' }
RsTsAddOptions >> onDuplicate: anObject [

	onDuplicate := anObject
]
