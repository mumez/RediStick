Class {
	#name : 'RsTsMRangeOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsTsMRangeOptions new asArray equals: #()
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testLatestFlag [
	| opts |
	opts := RsTsMRangeOptions new.
	opts latest.
	self assert: opts isLatest.
	self assertCollection: opts asArray equals: { 'LATEST' }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testFilterByTs [
	| opts |
	opts := RsTsMRangeOptions new.
	opts filterByTs: { 1000. 2000 }.
	self assertCollection: opts asArray equals: { 'FILTER_BY_TS'. 1000. 2000 }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testFilterByValue [
	| opts |
	opts := RsTsMRangeOptions new.
	opts filterByValueMin: -100 max: 100.
	self assertCollection: opts asArray equals: { 'FILTER_BY_VALUE'. -100. 100 }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testWithLabelsFlag [
	| opts |
	opts := RsTsMRangeOptions new.
	opts withLabels.
	self assert: opts isWithLabels.
	self assertCollection: opts asArray equals: { 'WITHLABELS' }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testSelectedLabels [
	| opts |
	opts := RsTsMRangeOptions new.
	opts selectedLabels: { 'region'. 'sensor' }.
	self assertCollection: opts asArray equals: { 'SELECTED_LABELS'. 'region'. 'sensor' }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testSelectedLabelsTakesPrecedenceOverWithLabels [
	| opts |
	opts := RsTsMRangeOptions new.
	opts withLabels; selectedLabels: { 'region' }.
	self assertCollection: opts asArray equals: { 'SELECTED_LABELS'. 'region' }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testCount [
	| opts |
	opts := RsTsMRangeOptions new.
	opts count: 5.
	self assertCollection: opts asArray equals: { 'COUNT'. 5 }
]

{ #category : 'tests' }
RsTsMRangeOptionsTest >> testAllOptionsCombinedInRedisOrder [
	| opts |
	opts := RsTsMRangeOptions new.
	opts
		latest;
		filterByTs: { 1000 };
		filterByValueMin: 0 max: 100;
		withLabels;
		count: 5.
	self assertCollection: opts asArray
		equals: { 'LATEST'. 'FILTER_BY_TS'. 1000. 'FILTER_BY_VALUE'. 0. 100. 'WITHLABELS'. 'COUNT'. 5 }
]
