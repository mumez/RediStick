Class {
	#name : 'RsTsValue',
	#superclass : 'Object',
	#instVars : [
		'key',
		'timestamp',
		'value',
		'labels'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'instance creation' }
RsTsValue class >> key: aKey timestamp: aTimestamp value: aValue labels: aLabelsDictionary [
	^ self new
		setKey: aKey
		timestamp: aTimestamp
		value: aValue
		labels: aLabelsDictionary
]

{ #category : 'accessing' }
RsTsValue >> key [
	^ key
]

{ #category : 'accessing' }
RsTsValue >> key: aKey [
	key := aKey
]

{ #category : 'accessing' }
RsTsValue >> labels [
	^ labels
]

{ #category : 'accessing' }
RsTsValue >> labels: aLabelsDictionary [
	labels := aLabelsDictionary
]

{ #category : 'accessing' }
RsTsValue >> timestamp [
	^ timestamp
]

{ #category : 'accessing' }
RsTsValue >> timestamp: aTimestamp [
	timestamp := aTimestamp
]

{ #category : 'accessing' }
RsTsValue >> value [
	^ value
]

{ #category : 'accessing' }
RsTsValue >> value: aValue [
	value := aValue
]

{ #category : 'private' }
RsTsValue >> setKey: aKey timestamp: aTimestamp value: aValue labels: aLabelsDictionary [
	self key: aKey.
	self timestamp: aTimestamp.
	self value: aValue.
	self labels: aLabelsDictionary
]
