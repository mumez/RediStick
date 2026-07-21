Class {
	#name : 'RsTsGroupByTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsGroupByTest >> testAsArrayShape [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'region'; reduce: 'sum'.
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'region'. 'REDUCE'. 'sum' }
]

{ #category : 'tests' }
RsTsGroupByTest >> testMissingLabelSignalsError [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy reduce: 'avg'.
	self should: [ groupBy asArray ] raise: Error
]

{ #category : 'tests' }
RsTsGroupByTest >> testMissingReducerSignalsError [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'region'.
	self should: [ groupBy asArray ] raise: Error
]
