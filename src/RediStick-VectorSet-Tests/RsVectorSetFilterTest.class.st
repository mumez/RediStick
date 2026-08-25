"
I test the fluent VSIM FILTER expression builder (RsVectorSetFilterElement
and friends), verifying the exact FILTER strings produced by #asFilterString.
No Redis connection is needed.
"
Class {
	#name : 'RsVectorSetFilterTest',
	#superclass : 'TestCase',
	#category : 'RediStick-VectorSet-Tests',
	#package : 'RediStick-VectorSet-Tests'
}

{ #category : 'tests' }
RsVectorSetFilterTest >> testEqual [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'foo') = 'bar') asFilterString equals: '.foo == "bar"'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testNotEqual [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'foo') ~= 'bar') asFilterString equals: '.foo != "bar"'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testGreaterThan [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'year') > 1980) asFilterString equals: '.year > 1980'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testGreaterThanOrEqual [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'year') >= 1980) asFilterString equals: '.year >= 1980'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testLessThan [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'rating') < 7) asFilterString equals: '.rating < 7'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testLessThanOrEqual [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'rating') <= 7) asFilterString equals: '.rating <= 7'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testInWithLiteralArray [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'color') in: #('red' 'blue')) asFilterString
		equals: '.color in ["red", "blue"]'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testAndOfTwoComparisonsHasNoSuperfluousParens [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: (((elem @ 'year') >= 1980) & ((elem @ 'rating') > 7)) asFilterString
		equals: '.year >= 1980 and .rating > 7'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testOrOfTwoComparisonsHasNoSuperfluousParens [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: (((elem @ 'year') >= 1980) | ((elem @ 'rating') > 7)) asFilterString
		equals: '.year >= 1980 or .rating > 7'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testNot [
	| elem |
	elem := RsVectorSetFilterElement new.
	self assert: ((elem @ 'foo') = 'bar') not asFilterString
		equals: '!(.foo == "bar")'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testMixedAndOrNeedsParensAroundOr [
	| elem expr |
	elem := RsVectorSetFilterElement new.
	expr := (((elem @ 'year') >= 1980) | ((elem @ 'year') = 0)) & ((elem @ 'rating') > 7).
	self assert: expr asFilterString
		equals: '(.year >= 1980 or .year == 0) and .rating > 7'
]

{ #category : 'tests' }
RsVectorSetFilterTest >> testMixedAndOrDoesNotAddParensWhenAndIsNestedInOr [
	| elem expr |
	elem := RsVectorSetFilterElement new.
	expr := (((elem @ 'year') >= 1980) & ((elem @ 'rating') > 7)) | ((elem @ 'color') = 'red').
	self assert: expr asFilterString
		equals: '.year >= 1980 and .rating > 7 or .color == "red"'
]
