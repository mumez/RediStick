Class {
	#name : 'RsTsNRangeRow',
	#superclass : 'Object',
	#instVars : [
		'timestamp',
		'values'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsNRangeRow class >> timestamp: aTimestamp values: aValuesArray [
	^ self new
		setTimestamp: aTimestamp
		values: aValuesArray
]

{ #category : 'accessing' }
RsTsNRangeRow >> timestamp [
	^ timestamp
]

{ #category : 'accessing' }
RsTsNRangeRow >> timestamp: aTimestamp [
	timestamp := aTimestamp
]

{ #category : 'accessing' }
RsTsNRangeRow >> values [
	^ values
]

{ #category : 'accessing' }
RsTsNRangeRow >> values: aValuesArray [
	values := aValuesArray
]

{ #category : 'printing' }
RsTsNRangeRow >> printOn: aStream [
	aStream
		nextPutAll: 'RsTsNRangeRow(timestamp: ';
		print: self timestamp;
		nextPutAll: ' values: ';
		print: self values;
		nextPut: $)
]

{ #category : 'testing' }
RsTsNRangeRow >> isRsTsNRangeRow [
	^ true
]

{ #category : 'private' }
RsTsNRangeRow >> setTimestamp: aTimestamp values: aValuesArray [
	self timestamp: aTimestamp.
	self values: aValuesArray
]
