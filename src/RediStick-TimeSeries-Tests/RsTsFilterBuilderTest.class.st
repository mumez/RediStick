Class {
	#name : 'RsTsFilterBuilderTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsFilterBuilderTest >> testNewBuilderHasNoFilters [
	self assert: RsTsFilterBuilder new filters isEmpty
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testSingleLabelEq [
	| builder |
	builder := RsTsFilterBuilder new.
	builder label: 'type' eq: 'temp'.
	self assert: builder filters size equals: 1.
	self assert: builder filters first asString equals: 'type=temp'
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testCascadeAddsMultipleFiltersInOrder [
	| builder |
	builder := RsTsFilterBuilder new.
	builder
		label: 'type' eq: 'temp';
		label: 'area' in: { 1. 2 };
		hasLabel: 'sensor'.
	self assert: builder filters size equals: 3.
	self assert: (builder filters collect: [ :f | f asString ])
		equals: { 'type=temp'. 'area=(1,2)'. 'sensor!=' }
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testBuilderMethodsAnswerSelf [
	| builder |
	builder := RsTsFilterBuilder new.
	self assert: (builder label: 'a' eq: 1) equals: builder
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testNoLabelAndNotIn [
	| builder |
	builder := RsTsFilterBuilder new.
	builder
		noLabel: 'deprecated';
		label: 'region' notIn: { 'eu'. 'us' }.
	self assert: (builder filters collect: [ :f | f asString ])
		equals: { 'deprecated='. 'region!=(eu,us)' }
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testValidateSignalsErrorWhenNoFilters [
	self should: [ RsTsFilterBuilder new validate ] raise: RsError
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testValidateSignalsErrorWhenOnlyExistenceMatchers [
	| builder |
	builder := RsTsFilterBuilder new.
	builder hasLabel: 'sensor_id'; noLabel: 'deprecated'.
	self should: [ builder validate ] raise: RsError
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testValidatePassesWithEqualityMatcher [
	| builder |
	builder := RsTsFilterBuilder new.
	builder hasLabel: 'sensor_id'; label: 'area' eq: 'kitchen'.
	builder validate
]

{ #category : 'tests' }
RsTsFilterBuilderTest >> testValidatePassesWithInMatcher [
	| builder |
	builder := RsTsFilterBuilder new.
	builder label: 'area' in: { 'kitchen'. 'living_room' }.
	builder validate
]
