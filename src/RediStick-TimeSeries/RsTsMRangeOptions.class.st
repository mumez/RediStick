"
I represent the optional parameters for a TS.MRANGE / TS.MREVRANGE command.

Responsibility:
- I hold the optional flags and filters that refine a multi-series range query: LATEST, FILTER_BY_TS, FILTER_BY_VALUE, WITHLABELS/SELECTED_LABELS, COUNT, and EXCLUDEEMPTY.
- I render my current settings as an ordered array of command arguments in the order Redis expects.

Collaborators:
- RsRedisEndpoint: builds me via an options block passed to #tsMRangeBy:filterBy:using: (and its MREVRANGE counterparts), then appends #asArray to the outgoing command.
- RsTsRange: used to normalize timestamps supplied to #filterByTs:.

Public API and Key Messages:
- #latest / #isLatest - request the latest (possibly partial) sample for each series
- #filterByTs: / #filterByTs - restrict returned samples to specific timestamps
- #filterByValueMin:max: - restrict returned samples to a value range
- #withLabels / #selectedLabels: - control which labels are returned per series
- #excludeEmpty / #isExcludeEmpty - omit series with no samples in the queried range (cannot be combined with GROUPBY)
- #count: - cap the number of samples returned per series
- #asArray - render the configured options as command arguments
"
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
		'count',
		'excludeEmpty'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsMRangeOptions >> initialize [
	super initialize.
	latest := false.
	withLabels := false.
	excludeEmpty := false
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

{ #category : 'accessing' }
RsTsMRangeOptions >> excludeEmpty [
	excludeEmpty := true
]

{ #category : 'accessing' }
RsTsMRangeOptions >> isExcludeEmpty [
	^ excludeEmpty
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
