Class {
	#name : 'RsTsMGetOptions',
	#superclass : 'Object',
	#instVars : [
		'latest',
		'withLabels',
		'selectedLabels'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'initialization' }
RsTsMGetOptions >> initialize [
	super initialize.
	latest := false.
	withLabels := false
]

{ #category : 'accessing' }
RsTsMGetOptions >> latest [
	latest := true
]

{ #category : 'accessing' }
RsTsMGetOptions >> isLatest [
	^ latest
]

{ #category : 'accessing' }
RsTsMGetOptions >> withLabels [
	withLabels := true
]

{ #category : 'accessing' }
RsTsMGetOptions >> isWithLabels [
	^ withLabels
]

{ #category : 'accessing' }
RsTsMGetOptions >> selectedLabels [
	^ selectedLabels
]

{ #category : 'accessing' }
RsTsMGetOptions >> selectedLabels: aCollectionOfLabels [
	selectedLabels := aCollectionOfLabels
]

{ #category : 'converting' }
RsTsMGetOptions >> asArray [
	| opts |
	opts := OrderedCollection new.
	self isLatest ifTrue: [ opts add: 'LATEST' ].
	self selectedLabels
		ifNotNil: [ :labels |
			opts add: 'SELECTED_LABELS'.
			opts addAll: labels ]
		ifNil: [ self isWithLabels ifTrue: [ opts add: 'WITHLABELS' ] ].
	^ opts asArray
]
