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

{ #category : 'tests' }
RsTsGroupByTest >> testReduceByAvg [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'; reduceBy: [ :r | r avg ].
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'area'. 'REDUCE'. 'avg' }
]

{ #category : 'tests' }
RsTsGroupByTest >> testReduceBySum [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'; reduceBy: [ :r | r sum ].
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'area'. 'REDUCE'. 'sum' }
]

{ #category : 'tests' }
RsTsGroupByTest >> testReduceByEmptyBlockSignalsError [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'.
	self should: [ groupBy reduceBy: [ :r | ] ] raise: Error
]

{ #category : 'tests' }
RsTsGroupByTest >> testReduceByAvgShortcut [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'; reduceByAvg.
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'area'. 'REDUCE'. 'avg' }
]

{ #category : 'tests' }
RsTsGroupByTest >> testReduceBySumShortcut [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'; reduceBySum.
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'area'. 'REDUCE'. 'sum' }
]

{ #category : 'tests' }
RsTsGroupByTest >> testReduceByMaxShortcut [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'; reduceByMax.
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'area'. 'REDUCE'. 'max' }
]

{ #category : 'tests' }
RsTsGroupByTest >> testReduceByMinShortcut [
	| groupBy |
	groupBy := RsTsGroupBy new.
	groupBy label: 'area'; reduceByMin.
	self assertCollection: groupBy asArray equals: { 'GROUPBY'. 'area'. 'REDUCE'. 'min' }
]
