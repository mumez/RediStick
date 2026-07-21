Class {
	#name : 'RsTsQueryIndexTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsQueryIndexTest >> testTsQueryIndexSingleFilterReturnsMatchingKey [
	| key result |
	key := 'test:ts:qi:single'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'qi' } ].

	result := stick endpoint tsQueryIndexFilterBy: [ :filter | filter label: 'type' eq: 'qi' ].
	self assert: (result includes: key)
]

{ #category : 'tests' }
RsTsQueryIndexTest >> testTsQueryIndexMultipleConjunctiveFilters [
	| keyA keyB result |
	keyA := 'test:ts:qi:conj:a'.
	keyB := 'test:ts:qi:conj:b'.
	stick endpoint tsCreate: keyA using: [ :opts | opts labels: { 'type' -> 'qiconj'. 'region' -> 'east' } ].
	stick endpoint tsCreate: keyB using: [ :opts | opts labels: { 'type' -> 'qiconj'. 'region' -> 'west' } ].

	result := stick endpoint tsQueryIndexFilterBy: [ :filter |
		filter
			label: 'type' eq: 'qiconj';
			label: 'region' eq: 'east' ].
	self assert: (result includes: keyA).
	self deny: (result includes: keyB)
]

{ #category : 'tests' }
RsTsQueryIndexTest >> testTsQueryIndexWithLabelInFilter [
	| keyA keyB keyC result |
	keyA := 'test:ts:qi:in:a'.
	keyB := 'test:ts:qi:in:b'.
	keyC := 'test:ts:qi:in:c'.
	stick endpoint tsCreate: keyA using: [ :opts | opts labels: { 'type' -> 'qiin'. 'zone' -> 'z1' } ].
	stick endpoint tsCreate: keyB using: [ :opts | opts labels: { 'type' -> 'qiin'. 'zone' -> 'z2' } ].
	stick endpoint tsCreate: keyC using: [ :opts | opts labels: { 'type' -> 'qiin'. 'zone' -> 'z3' } ].

	result := stick endpoint tsQueryIndexFilterBy: [ :filter |
		filter
			label: 'type' eq: 'qiin';
			label: 'zone' in: { 'z1'. 'z2' } ].
	self assert: (result includes: keyA).
	self assert: (result includes: keyB).
	self deny: (result includes: keyC)
]

{ #category : 'tests' }
RsTsQueryIndexTest >> testTsQueryIndexNoMatchReturnsEmptyArray [
	| result |
	result := stick endpoint tsQueryIndexFilterBy: [ :filter |
		filter label: 'type' eq: 'test:ts:qi:nomatch:zzz' ].
	self assertCollection: result equals: #()
]

{ #category : 'tests' }
RsTsQueryIndexTest >> testTsQueryIndexWithoutFiltersSignalsError [
	self should: [ stick endpoint tsQueryIndexFilterBy: [ :filter | ] ] raise: Error
]
