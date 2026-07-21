Class {
	#name : 'RsTsMGetTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetSingleFilterReturnsLatestSample [
	| key |
	key := 'test:ts:mget:single'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'temp' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.

	self assert: (stick endpoint
		tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'temp' ]) size equals: 1.
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetReturnsKeyTimestampAndValue [
	| key result tsValue |
	key := 'test:ts:mget:kv'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'kv' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.

	result := stick endpoint tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'kv' ].
	tsValue := result first.
	self assert: tsValue key equals: key.
	self assert: tsValue timestamp equals: 1010.
	self assert: tsValue value equals: 35
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetDefaultsToEmptyLabels [
	| key result |
	key := 'test:ts:mget:nolabels'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'nolab' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 5.

	result := stick endpoint tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'nolab' ].
	self assert: result first labels isEmpty
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetWithLabelsOption [
	| key result labels |
	key := 'test:ts:mget:withlabels'.
	stick endpoint tsCreate: key using: [ :opts |
		opts labels: { 'type' -> 'wl'. 'area' -> 'north' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 5.

	result := stick endpoint
		tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'wl' ]
		using: [ :opts | opts withLabels ].
	labels := result first labels.
	self assert: (labels at: 'type') equals: 'wl'.
	self assert: (labels at: 'area') equals: 'north'
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetWithSelectedLabelsOption [
	| key result labels |
	key := 'test:ts:mget:selectedlabels'.
	stick endpoint tsCreate: key using: [ :opts |
		opts labels: { 'type' -> 'sl'. 'area' -> 'south' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 5.

	result := stick endpoint
		tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'sl' ]
		using: [ :opts | opts selectedLabels: { 'area' } ].
	labels := result first labels.
	self assert: (labels at: 'area') equals: 'south'.
	self deny: (labels includesKey: 'type')
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetWithLatestOptionOnPlainSeries [
	"LATEST is ignored for non-compaction series; verifying it is accepted without error."
	| key result |
	key := 'test:ts:mget:latest'.
	stick endpoint tsCreate: key using: [ :opts | opts labels: { 'type' -> 'lat' } ].
	stick endpoint tsAdd: key timestamp: 1000 value: 11.

	result := stick endpoint
		tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'lat' ]
		using: [ :opts | opts latest ].
	self assert: result first value equals: 11
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetMultipleFiltersAreConjunctive [
	| tlv jlm result |
	tlv := 'test:ts:mget:multi:tlv'.
	jlm := 'test:ts:mget:multi:jlm'.
	stick endpoint tsCreate: tlv using: [ :opts | opts labels: { 'type' -> 'multi'. 'city' -> 'TLV' } ].
	stick endpoint tsCreate: jlm using: [ :opts | opts labels: { 'type' -> 'multi'. 'city' -> 'JLM' } ].
	stick endpoint tsAdd: tlv timestamp: 1000 value: 30.
	stick endpoint tsAdd: jlm timestamp: 1000 value: 20.

	result := stick endpoint tsMGetFilterBy: [ :filter |
		filter
			label: 'type' eq: 'multi';
			label: 'city' eq: 'TLV' ].
	self assert: result size equals: 1.
	self assert: result first key equals: tlv
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetWithLabelInFilter [
	| tlv jlm ny result keys |
	tlv := 'test:ts:mget:in:tlv'.
	jlm := 'test:ts:mget:in:jlm'.
	ny := 'test:ts:mget:in:ny'.
	stick endpoint tsCreate: tlv using: [ :opts | opts labels: { 'type' -> 'inflt'. 'city' -> 'TLV' } ].
	stick endpoint tsCreate: jlm using: [ :opts | opts labels: { 'type' -> 'inflt'. 'city' -> 'JLM' } ].
	stick endpoint tsCreate: ny using: [ :opts | opts labels: { 'type' -> 'inflt'. 'city' -> 'NY' } ].
	stick endpoint tsAdd: tlv timestamp: 1000 value: 1.
	stick endpoint tsAdd: jlm timestamp: 1000 value: 2.
	stick endpoint tsAdd: ny timestamp: 1000 value: 3.

	result := stick endpoint tsMGetFilterBy: [ :filter |
		filter
			label: 'type' eq: 'inflt';
			label: 'city' in: { 'TLV'. 'JLM' } ].
	self assert: result size equals: 2.
	keys := result collect: [ :tsValue | tsValue key ].
	self assert: (keys includes: tlv).
	self assert: (keys includes: jlm).
	self deny: (keys includes: ny)
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetNoMatchingSeriesReturnsEmptyArray [
	self assertCollection:
		(stick endpoint tsMGetFilterBy: [ :filter | filter label: 'type' eq: 'test:ts:mget:nomatch' ])
		equals: #()
]

{ #category : 'tests' }
RsTsMGetTest >> testTsMGetWithoutFiltersSignalsError [
	self should: [ stick endpoint tsMGetFilterBy: [ :filter | ] ] raise: Error
]
