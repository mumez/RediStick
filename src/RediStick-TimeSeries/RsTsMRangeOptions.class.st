Class {
	#name : 'RsTsMRangeOptions',
	#superclass : 'Object',
	#instVars : [
		'latest',
		'filterByTs',
		'filterByValueMin',
		'filterByValueMax',
		'withLabels',
		'selectedLabels',
		'count'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsMRangeOptions >> initialize [
	super initialize.
	latest := false.
	withLabels := false
]

{ #category : 'accessing' }
RsTsMRangeOptions >> latest [
	latest := true
]

{ #category : 'accessing' }
RsTsMRangeOptions >> isLatest [
	^ latest
]

{ #category : 'accessing' }
RsTsMRangeOptions >> filterByTs: aCollectionOfTimestamps [
	filterByTs := aCollectionOfTimestamps collect: [ :ts | RsTsRange normalizeTimestamp: ts ]
]

{ #category : 'accessing' }
RsTsMRangeOptions >> filterByTs [
	^ filterByTs
]

{ #category : 'accessing' }
RsTsMRangeOptions >> filterByValueMin: aMin max: aMax [
	filterByValueMin := aMin.
	filterByValueMax := aMax
]

{ #category : 'accessing' }
RsTsMRangeOptions >> filterByValueMin [
	^ filterByValueMin
]

{ #category : 'accessing' }
RsTsMRangeOptions >> filterByValueMax [
	^ filterByValueMax
]

{ #category : 'accessing' }
RsTsMRangeOptions >> withLabels [
	withLabels := true
]

{ #category : 'accessing' }
RsTsMRangeOptions >> isWithLabels [
	^ withLabels
]

{ #category : 'accessing' }
RsTsMRangeOptions >> selectedLabels: aCollectionOfLabels [
	selectedLabels := aCollectionOfLabels
]

{ #category : 'accessing' }
RsTsMRangeOptions >> selectedLabels [
	^ selectedLabels
]

{ #category : 'accessing' }
RsTsMRangeOptions >> count: anInteger [
	count := anInteger
]

{ #category : 'accessing' }
RsTsMRangeOptions >> count [
	^ count
]

{ #category : 'converting' }
RsTsMRangeOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	self isLatest ifTrue: [ opts add: 'LATEST' ].
	self filterByTs ifNotNil: [ :ts |
		opts add: 'FILTER_BY_TS'.
		opts addAll: ts ].
	(self filterByValueMin notNil and: [ self filterByValueMax notNil ]) ifTrue: [
		opts addAll: { 'FILTER_BY_VALUE'. self filterByValueMin. self filterByValueMax } ].
	self selectedLabels
		ifNotNil: [ :labels |
			opts add: 'SELECTED_LABELS'.
			opts addAll: labels ]
		ifNil: [ self isWithLabels ifTrue: [ opts add: 'WITHLABELS' ] ].
	self count ifNotNil: [ :c | opts addAll: { 'COUNT'. c } ].
	^ opts asArray
]
