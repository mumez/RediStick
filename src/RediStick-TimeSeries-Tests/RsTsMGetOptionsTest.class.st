Class {
	#name : 'RsTsMGetOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsMGetOptionsTest >> testEmptyOptionsProduceEmptyArray [
	self assertCollection: RsTsMGetOptions new asArray equals: #()
]

{ #category : 'tests' }
RsTsMGetOptionsTest >> testLatestFlag [
	| opts |
	opts := RsTsMGetOptions new.
	opts latest.
	self assert: opts isLatest.
	self assertCollection: opts asArray equals: { 'LATEST' }
]

{ #category : 'tests' }
RsTsMGetOptionsTest >> testWithLabelsFlag [
	| opts |
	opts := RsTsMGetOptions new.
	opts withLabels.
	self assert: opts isWithLabels.
	self assertCollection: opts asArray equals: { 'WITHLABELS' }
]

{ #category : 'tests' }
RsTsMGetOptionsTest >> testSelectedLabels [
	| opts |
	opts := RsTsMGetOptions new.
	opts selectedLabels: { 'region'. 'sensor' }.
	self assertCollection: opts asArray equals: { 'SELECTED_LABELS'. 'region'. 'sensor' }
]

{ #category : 'tests' }
RsTsMGetOptionsTest >> testSelectedLabelsTakesPrecedenceOverWithLabels [
	| opts |
	opts := RsTsMGetOptions new.
	opts withLabels; selectedLabels: { 'region' }.
	self assertCollection: opts asArray equals: { 'SELECTED_LABELS'. 'region' }
]

{ #category : 'tests' }
RsTsMGetOptionsTest >> testLatestAndWithLabelsCombinedInOrder [
	| opts |
	opts := RsTsMGetOptions new.
	opts latest; withLabels.
	self assertCollection: opts asArray equals: { 'LATEST'. 'WITHLABELS' }
]
