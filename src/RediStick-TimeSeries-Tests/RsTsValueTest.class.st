Class {
	#name : 'RsTsValueTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsValueTest >> testAccessors [
	| labels tsValue |
	labels := { 'region' -> 'eu' } asDictionary.
	tsValue := RsTsValue
		key: 'temp:TLV'
		timestamp: 1030
		value: 40
		labels: labels.
	self assert: tsValue key equals: 'temp:TLV'.
	self assert: tsValue timestamp equals: 1030.
	self assert: tsValue value equals: 40.
	self assert: tsValue labels equals: labels
]

{ #category : 'tests' }
RsTsValueTest >> testEmptyLabels [
	| tsValue |
	tsValue := RsTsValue key: 'k' timestamp: 1 value: 2 labels: Dictionary new.
	self assert: tsValue labels isEmpty
]
