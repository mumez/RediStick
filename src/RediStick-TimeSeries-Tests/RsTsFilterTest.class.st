Class {
	#name : 'RsTsFilterTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsFilterTest >> testLabelEq [
	self assert: (RsTsFilter label: 'type' eq: 'temp') asString equals: 'type=temp'
]

{ #category : 'tests' }
RsTsFilterTest >> testLabelNotEq [
	self assert: (RsTsFilter label: 'type' notEq: 'temp') asString equals: 'type!=temp'
]

{ #category : 'tests' }
RsTsFilterTest >> testLabelIn [
	self assert: (RsTsFilter label: 'area' in: { 1. 2. 3 }) asString equals: 'area=(1,2,3)'
]

{ #category : 'tests' }
RsTsFilterTest >> testLabelNotIn [
	self assert: (RsTsFilter label: 'area' notIn: { 'a'. 'b' }) asString equals: 'area!=(a,b)'
]

{ #category : 'tests' }
RsTsFilterTest >> testHasLabel [
	self assert: (RsTsFilter hasLabel: 'sensor') asString equals: 'sensor!='
]

{ #category : 'tests' }
RsTsFilterTest >> testNoLabel [
	self assert: (RsTsFilter noLabel: 'sensor') asString equals: 'sensor='
]

{ #category : 'tests' }
RsTsFilterTest >> testLabelInWithSingleValue [
	self assert: (RsTsFilter label: 'area' in: { 1 }) asString equals: 'area=(1)'
]
