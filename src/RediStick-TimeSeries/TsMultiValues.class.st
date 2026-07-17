Class {
	#name : 'TsMultiValues',
	#superclass : 'Object',
	#instVars : [
		'triplets'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}


{ #category : 'instance creation' }
TsMultiValues class >> fromDictionary: aDictionary [
	| mv |
	mv := self new.
	aDictionary associationsDo: [ :assoc | mv key: assoc key value: assoc value ].
	^ mv
]

{ #category : 'instance creation' }
TsMultiValues class >> fromKeyTimestampValues: aCollection [
	| mv |
	mv := self new.
	aCollection do: [ :triplet | mv key: triplet first timestamp: triplet second value: triplet third ].
	^ mv
]

{ #category : 'instance creation' }
TsMultiValues class >> fromKeyValues: aCollection [
	| mv |
	mv := self new.
	aCollection do: [ :assoc | mv key: assoc key value: assoc value ].
	^ mv
]

{ #category : 'initialization' }
TsMultiValues >> initialize [
	triplets := OrderedCollection new
]

{ #category : 'fluent interface' }
TsMultiValues >> key: key timestamp: aTimestamp value: value [
	self triplets add: { key. aTimestamp asRediStickUnixTimestampMillis. value }.
	^ self
]

{ #category : 'fluent interface' }
TsMultiValues >> key: key value: value [
	self triplets add: { key. '*'. value }.
	^ self
]

{ #category : 'accessing' }
TsMultiValues >> triplets [
	^ triplets
]
