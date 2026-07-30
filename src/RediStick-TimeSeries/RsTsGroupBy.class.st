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

{ #category : 'accessing' }
RsTsGroupBy >> reduceBy: aBlock [
	| r |
	r := RsTsReducer new.
	aBlock value: r.
	r reducerName ifNil: [ (RsError invalidArguments) signal: 'reducer block must set a reducer' ].
	reducer := r reducerName
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByAvg [
	self reduceBy: [ :r | r avg ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByCount [
	self reduceBy: [ :r | r count ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByFirst [
	self reduceBy: [ :r | r first ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByLast [
	self reduceBy: [ :r | r last ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByMax [
	self reduceBy: [ :r | r max ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByMin [
	self reduceBy: [ :r | r min ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByRange [
	self reduceBy: [ :r | r range ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByStdP [
	self reduceBy: [ :r | r stdP ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByStdS [
	self reduceBy: [ :r | r stdS ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceBySum [
	self reduceBy: [ :r | r sum ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByTwa [
	self reduceBy: [ :r | r twa ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByVarP [
	self reduceBy: [ :r | r varP ]
]

{ #category : 'shortcuts-reducer' }
RsTsGroupBy >> reduceByVarS [
	self reduceBy: [ :r | r varS ]
]

{ #category : 'converting' }
RsTsGroupBy >> asArray [
	self label ifNil: [ (RsError invalidArguments) signal: 'label must be set' ].
	self reducer ifNil: [ (RsError invalidArguments) signal: 'reducer must be set' ].
	^ { 'GROUPBY'. self label. 'REDUCE'. self reducer }
]
