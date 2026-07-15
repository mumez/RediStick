Class {
	#name : 'RsTsRangeTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsRangeTest >> testAllUsesStartAndEnd [
	| range |
	range := RsTsRange all.
	self assert: range from equals: '-'.
	self assert: range to equals: '+'
]

{ #category : 'tests' }
RsTsRangeTest >> testAsArray [
	| range |
	range := RsTsRange from: 1000 to: 2000.
	self assertCollection: range asArray equals: { 1000. 2000 }
]

{ #category : 'tests' }
RsTsRangeTest >> testFromToWithIntegers [
	| range |
	range := RsTsRange from: 1000 to: 2000.
	self assert: range from equals: 1000.
	self assert: range to equals: 2000
]

{ #category : 'tests' }
RsTsRangeTest >> testFromOnlyDefaultsToEnd [
	| range |
	range := RsTsRange from: 1000.
	self assert: range from equals: 1000.
	self assert: range to equals: '+'
]

{ #category : 'tests' }
RsTsRangeTest >> testToOnlyDefaultsFromStart [
	| range |
	range := RsTsRange to: 2000.
	self assert: range from equals: '-'.
	self assert: range to equals: 2000
]

{ #category : 'tests' }
RsTsRangeTest >> testStartAndEndSentinels [
	self assert: RsTsRange start equals: '-'.
	self assert: RsTsRange end equals: '+'
]

{ #category : 'tests' }
RsTsRangeTest >> testFromToWithDateAndTime [
	| now range |
	now := DateAndTime now.
	range := RsTsRange from: now to: now.
	self assert: range from equals: now asRediStickUnixTimestampMillis.
	self assert: range to equals: now asRediStickUnixTimestampMillis
]
