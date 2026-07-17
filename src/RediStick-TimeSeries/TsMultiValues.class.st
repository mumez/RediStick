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
	| inst |
	inst := self new.
	aDictionary associationsDo: [ :assoc | inst key: assoc key value: assoc value ].
	^ inst
]

{ #category : 'instance creation' }
TsMultiValues class >> fromKeyTimestampValues: aCollection [
	| inst |
	inst := self new.
	aCollection do: [ :triplet | inst key: triplet first timestamp: triplet second value: triplet third ].
	^ inst
]

{ #category : 'instance creation' }
TsMultiValues class >> fromKeyValues: aCollection [
	| mv |
	inst := self new.
	aCollection do: [ :pair | inst key: pair first value: pair last ].
	^ inst
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
