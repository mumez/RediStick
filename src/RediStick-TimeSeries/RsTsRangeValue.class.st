Class {
	#name : 'RsTsRangeValue',
	#superclass : 'Object',
	#instVars : [
		'key',
		'labels',
		'values'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsRangeValue class >> key: aKey labels: aLabelsDictionary values: aValuesArray [
	^ self new
		setKey: aKey
		labels: aLabelsDictionary
		values: aValuesArray
]

{ #category : 'accessing' }
RsTsRangeValue >> key [
	^ key
]

{ #category : 'accessing' }
RsTsRangeValue >> key: aKey [
	key := aKey
]

{ #category : 'accessing' }
RsTsRangeValue >> labels [
	^ labels
]

{ #category : 'accessing' }
RsTsRangeValue >> labels: aLabelsDictionary [
	labels := aLabelsDictionary
]

{ #category : 'accessing' }
RsTsRangeValue >> values [
	^ values
]

{ #category : 'accessing' }
RsTsRangeValue >> values: aValuesArray [
	values := aValuesArray
]

{ #category : 'printing' }
RsTsRangeValue >> printOn: aStream [
	aStream
		nextPutAll: 'RsTsRangeValue(key: ';
		print: self key;
		nextPutAll: ' labels: ';
		print: self labels;
		nextPutAll: ' values: ';
		print: self values;
		nextPut: $)
]

{ #category : 'testing' }
RsTsRangeValue >> isRsTsRangeValue [
	^ true
]

{ #category : 'private' }
RsTsRangeValue >> setKey: aKey labels: aLabelsDictionary values: aValuesArray [
	self key: aKey.
	self labels: aLabelsDictionary.
	self values: aValuesArray
]
