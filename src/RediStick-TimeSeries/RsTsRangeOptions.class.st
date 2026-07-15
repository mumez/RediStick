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
	self isLatest ifTrue: [ opts add: 'LATEST' ].
	self filterByTs ifNotNil: [ :ts |
		opts add: 'FILTER_BY_TS'.
		opts addAll: ts ].
	(self filterByValueMin notNil and: [ self filterByValueMax notNil ]) ifTrue: [
		opts addAll: { 'FILTER_BY_VALUE'. self filterByValueMin. self filterByValueMax } ].
	self count ifNotNil: [ :c | opts addAll: { 'COUNT'. c } ].
	^ opts asArray
]

{ #category : 'accessing' }
RsTsRangeOptions >> count [
	^ count
]

{ #category : 'accessing' }
RsTsRangeOptions >> count: anInteger [
	count := anInteger
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByTs [
	^ filterByTs
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByTs: aCollectionOfTimestamps [
	filterByTs := aCollectionOfTimestamps collect: [ :ts | RsTsRange normalizeTimestamp: ts ]
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByValueMax [
	^ filterByValueMax
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByValueMin [
	^ filterByValueMin
]

{ #category : 'accessing' }
RsTsRangeOptions >> filterByValueMin: aMin max: aMax [
	filterByValueMin := aMin.
	filterByValueMax := aMax
]

{ #category : 'accessing' }
RsTsRangeOptions >> isLatest [
	^ latest
]

{ #category : 'accessing' }
RsTsRangeOptions >> latest [
	latest := true
]
