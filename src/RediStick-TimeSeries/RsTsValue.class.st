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
RsTsValue >> labels [
	^ labels
]

{ #category : 'accessing' }
RsTsValue >> timestamp [
	^ timestamp
]

{ #category : 'accessing' }
RsTsValue >> value [
	^ value
]

{ #category : 'private' }
RsTsValue >> setKey: aKey timestamp: aTimestamp value: aValue labels: aLabelsDictionary [
	key := aKey.
	timestamp := aTimestamp.
	value := aValue.
	labels := aLabelsDictionary
]
