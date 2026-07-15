Class {
	#name : 'RsTsRangeOptions',
	#superclass : 'Object',
	#instVars : [
		'latest',
		'filterByTs',
		'filterByValueMin',
		'filterByValueMax',
		'count'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsRangeOptions >> initialize [
	super initialize.
	latest := false
]

{ #category : 'converting' }
RsTsRangeOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	latest ifTrue: [ opts add: 'LATEST' ].
	filterByTs ifNotNil: [ :ts |
		opts add: 'FILTER_BY_TS'.
		opts addAll: ts ].
	(filterByValueMin notNil and: [ filterByValueMax notNil ]) ifTrue: [
		opts addAll: { 'FILTER_BY_VALUE'. filterByValueMin. filterByValueMax } ].
	count ifNotNil: [ :c | opts addAll: { 'COUNT'. c } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsRangeOptions >> count: anInteger [
	count := anInteger
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByTs: aCollectionOfTimestamps [
	filterByTs := aCollectionOfTimestamps collect: [ :ts |
		ts isString ifTrue: [ ts ] ifFalse: [ ts asRediStickUnixTimestampMillis ] ]
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByValueMin: aMin max: aMax [
	filterByValueMin := aMin.
	filterByValueMax := aMax
]

{ #category : 'accessing' }
RsTsRangeOptions >> latest [
	latest := true
]
