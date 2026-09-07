Class {
	#name : 'RsTsReadOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsReadOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsTsReadOptions new asArray equals: #()
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testBlock [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 5000 minCount: 2.
	self assertCollection: opts asArray equals: { 'BLOCK'. 5000. 2 }
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testMaxCount [
	| opts |
	opts := RsTsReadOptions new.
	opts maxCount: 10.
	self assertCollection: opts asArray equals: { 'MAX_COUNT'. 10 }
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testBlockAndMaxCountCombinedInRedisOrder [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 1000 minCount: 5; maxCount: 20.
	self assertCollection: opts asArray equals: { 'BLOCK'. 1000. 5. 'MAX_COUNT'. 20 }
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testBlockWithoutMinCountIsIgnored [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 1000 minCount: nil.
	self assertCollection: opts asArray equals: #()
]

{ #category : 'tests' }
RsTsReadOptionsTest >> testAccessors [
	| opts |
	opts := RsTsReadOptions new.
	opts block: 1500 minCount: 3; maxCount: 7.
	self assert: opts blockMilliseconds equals: 1500.
	self assert: opts blockMinCount equals: 3.
	self assert: opts maxCount equals: 7
]
