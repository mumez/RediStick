Class {
	#name : 'RsTsGroupBy',
	#superclass : 'Object',
	#instVars : [
		'label',
		'reducer'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'accessing' }
RsTsGroupBy >> label [
	^ label
]

{ #category : 'accessing' }
RsTsGroupBy >> label: aLabel [
	label := aLabel
]

{ #category : 'accessing' }
RsTsGroupBy >> reducer [
	^ reducer
]

{ #category : 'accessing' }
RsTsGroupBy >> reduce: aReducer [
	reducer := aReducer
]

{ #category : 'converting' }
RsTsGroupBy >> asArray [
	self label ifNil: [ Error signal: 'label must be set' ].
	self reducer ifNil: [ Error signal: 'reducer must be set' ].
	^ { 'GROUPBY'. self label. 'REDUCE'. self reducer }
]
