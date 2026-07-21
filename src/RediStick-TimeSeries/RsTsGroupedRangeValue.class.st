Class {
	#name : 'RsTsGroupedRangeValue',
	#superclass : 'Object',
	#instVars : [
		'key',
		'labels',
		'groupByLabel',
		'reducer',
		'sourceKeys',
		'values'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsGroupedRangeValue class >> key: aKey labels: aLabelsDictionary groupByLabel: anAssociation reducer: aReducer sourceKeys: aSourceKeysArray values: aValuesArray [
	^ self new
		setKey: aKey
		labels: aLabelsDictionary
		groupByLabel: anAssociation
		reducer: aReducer
		sourceKeys: aSourceKeysArray
		values: aValuesArray
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> key [
	^ key
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> key: aKey [
	key := aKey
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> labels [
	^ labels
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> labels: aLabelsDictionary [
	labels := aLabelsDictionary
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> groupByLabel [
	^ groupByLabel
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> groupByLabel: anAssociation [
	groupByLabel := anAssociation
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> reducer [
	^ reducer
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> reducer: aReducer [
	reducer := aReducer
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> sourceKeys [
	^ sourceKeys
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> sourceKeys: aSourceKeysArray [
	sourceKeys := aSourceKeysArray
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> values [
	^ values
]

{ #category : 'accessing' }
RsTsGroupedRangeValue >> values: aValuesArray [
	values := aValuesArray
]

{ #category : 'testing' }
RsTsGroupedRangeValue >> isRsTsGroupedRangeValue [
	^ true
]

{ #category : 'private' }
RsTsGroupedRangeValue >> setKey: aKey labels: aLabelsDictionary groupByLabel: anAssociation reducer: aReducer sourceKeys: aSourceKeysArray values: aValuesArray [
	self key: aKey.
	self labels: aLabelsDictionary.
	self groupByLabel: anAssociation.
	self reducer: aReducer.
	self sourceKeys: aSourceKeysArray.
	self values: aValuesArray
]
