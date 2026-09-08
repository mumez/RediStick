Class {
	#name : 'RsTsQueryLabelsTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelsReturnsDistinctLabelNames [
	| result |
	stick endpoint tsCreate: 'test:ts:ql:labels:a' using: [ :opts | opts labels: { 'type' -> 'ql'. 'region' -> 'east' } ].
	stick endpoint tsCreate: 'test:ts:ql:labels:b' using: [ :opts | opts labels: { 'type' -> 'ql' } ].

	result := stick endpoint tsQueryLabels.
	self assert: (result includes: 'type').
	self assert: (result includes: 'region')
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelsFilterBySingleFilter [
	| keyA keyB result |
	keyA := 'test:ts:ql:single:a'.
	keyB := 'test:ts:ql:single:b'.
	stick endpoint tsCreate: keyA using: [ :opts | opts labels: { 'type' -> 'qlsingle'. 'region' -> 'east' } ].
	stick endpoint tsCreate: keyB using: [ :opts | opts labels: { 'type' -> 'other'. 'zone' -> 'z1' } ].

	result := stick endpoint tsQueryLabelsFilterBy: [ :filter | filter label: 'type' eq: 'qlsingle' ].
	self assert: (result includes: 'region').
	self deny: (result includes: 'zone')
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelsFilterByConjunctiveFilters [
	| keyA keyB result |
	keyA := 'test:ts:ql:conj:a'.
	keyB := 'test:ts:ql:conj:b'.
	stick endpoint tsCreate: keyA using: [ :opts | opts labels: { 'type' -> 'qlconj'. 'region' -> 'east'. 'onlyA' -> 'x' } ].
	stick endpoint tsCreate: keyB using: [ :opts | opts labels: { 'type' -> 'qlconj'. 'region' -> 'west' } ].

	result := stick endpoint tsQueryLabelsFilterBy: [ :filter |
		filter
			label: 'type' eq: 'qlconj';
			label: 'region' eq: 'east' ].
	self assert: (result includes: 'onlyA')
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelsFilterByWithoutFiltersSignalsError [
	self should: [ stick endpoint tsQueryLabelsFilterBy: [ :filter | ] ] raise: Error
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelValuesReturnsDistinctValues [
	| result |
	stick endpoint tsCreate: 'test:ts:ql:values:a' using: [ :opts | opts labels: { 'type' -> 'qlvala' } ].
	stick endpoint tsCreate: 'test:ts:ql:values:b' using: [ :opts | opts labels: { 'type' -> 'qlvalb' } ].

	result := stick endpoint tsQueryLabelValuesOf: 'type'.
	self assert: (result includes: 'qlvala').
	self assert: (result includes: 'qlvalb')
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelValuesForNonExistentLabelReturnsEmptyArray [
	| result |
	result := stick endpoint tsQueryLabelValuesOf: 'test:ts:ql:nolabel:zzz'.
	self assertCollection: result equals: #()
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelValuesFilterByFiltered [
	| keyA keyB result |
	keyA := 'test:ts:ql:valfilt:a'.
	keyB := 'test:ts:ql:valfilt:b'.
	stick endpoint tsCreate: keyA using: [ :opts | opts labels: { 'type' -> 'qlvalfilt'. 'region' -> 'east' } ].
	stick endpoint tsCreate: keyB using: [ :opts | opts labels: { 'type' -> 'other'. 'region' -> 'west' } ].

	result := stick endpoint tsQueryLabelValuesOf: 'region' filterBy: [ :filter | filter label: 'type' eq: 'qlvalfilt' ].
	self assert: (result includes: 'east').
	self deny: (result includes: 'west')
]

{ #category : 'tests' }
RsTsQueryLabelsTest >> testTsQueryLabelValuesFilterByWithoutFiltersSignalsError [
	self should: [ stick endpoint tsQueryLabelValuesOf: 'type' filterBy: [ :filter | ] ] raise: Error
]
