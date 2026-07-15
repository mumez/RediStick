Class {
	#name : 'RsTsTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsTest >> testTsAddAutoTimestamp [
	| key result |
	key := 'test:ts:add:auto'.
	result := stick endpoint tsAdd: key value: 27.
	self assert: result isNumber.
	self assert: (stick endpoint tsGet: key) value equals: 27
]

{ #category : 'tests' }
RsTsTest >> testTsAddCreatesKeyWithLabels [
	| key result labels info |
	key := 'test:ts:add:labels'.
	result := stick endpoint
		tsAdd: key
		timestamp: 1000
		value: 30
		using: [ :opts | opts labels: { 'sensor_id' -> '2'. 'area_id' -> '32' } ].
	self assert: result equals: 1000.
	self assert: (stick endpoint tsGet: key) key equals: 1000.
	info := stick endpoint tsInfo: key.
	self assert: info isNotNil.
	labels := self labelsAsDictionary: (info at: 'labels').
	self assert: (labels at: 'sensor_id') equals: '2'.
	self assert: (labels at: 'area_id') equals: '32'
]

{ #category : 'tests' }
RsTsTest >> testTsAddWithDateAndTime [
	| key now result |
	key := 'test:ts:add:datetime'.
	now := DateAndTime now.
	result := stick endpoint tsAdd: key timestamp: now value: 42.
	self assert: result equals: now asRediStickUnixTimestampMillis
]

{ #category : 'tests' }
RsTsTest >> testTsAddWithExplicitTimestamp [
	| key result |
	key := 'test:ts:add:explicit'.
	result := stick endpoint tsAdd: key timestamp: 1000 value: 30.
	self assert: result equals: 1000
]

{ #category : 'tests' }
RsTsTest >> testTsAddAutoTimestampWithOptions [
	| key result |
	key := 'test:ts:add:auto:options'.
	result := stick endpoint
		tsAdd: key
		value: 55
		using: [ :opts | opts retention: 60000; encoding: 'UNCOMPRESSED' ].
	self assert: result isNumber.
	self assert: (stick endpoint tsGet: key) value equals: 55
]

{ #category : 'tests' }
RsTsTest >> testTsAddWithOptions [
	| key result |
	key := 'test:ts:add:options'.
	result := stick endpoint
		tsAdd: key
		timestamp: 1000
		value: 30
		using: [ :opts | opts retention: 60000; encoding: 'UNCOMPRESSED' ].
	self assert: result equals: 1000
]

{ #category : 'tests' }
RsTsTest >> testTsCreateBasic [
	| key result |
	key := 'test:ts:create:basic'.
	result := stick endpoint tsCreate: key.
	self assert: result equals: 'OK'
]

{ #category : 'tests' }
RsTsTest >> testTsCreateWithLabels [
	| key result labels info |
	key := 'test:ts:create:labels'.
	result := stick endpoint
		tsCreate: key
		using: [ :opts |
			opts
				retention: 60000;
				duplicatePolicy: 'MAX';
				labels: { 'sensor_id' -> '2'. 'area_id' -> '32' } ].
	self assert: result equals: 'OK'.
	info := stick endpoint tsInfo: key.
	self assert: info isNotNil.
	labels := self labelsAsDictionary: (info at: 'labels').
	self assert: (labels at: 'sensor_id') equals: '2'.
	self assert: (labels at: 'area_id') equals: '32'.
	self assert: (info at: 'duplicatePolicy') equals: 'max'
]

{ #category : 'tests' }
RsTsTest >> testTsCreateWithOptions [
	| key result info |
	key := 'test:ts:create:options'.
	result := stick endpoint
		tsCreate: key
		using: [ :opts |
			opts
				retention: 60000;
				encoding: 'COMPRESSED';
				chunkSize: 4096 ].
	self assert: result equals: 'OK'.
	info := stick endpoint tsInfo: key.
	self assert: info isNotNil.
	self assert: (info at: 'retentionTime') equals: 60000.
	self assert: (info at: 'chunkSize') equals: 4096.
	self assert: (info at: 'chunkType') equals: 'compressed'
]

{ #category : 'tests' }
RsTsTest >> testTsDelRemovesSamples [
	| key result |
	key := 'test:ts:del'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsDel: key from: 1000 to: 1010.
	self assert: result equals: 2.
	self assert: (stick endpoint tsGet: key) key equals: 1020
]

{ #category : 'tests' }
RsTsTest >> testTsGetEmptySeries [
	| key |
	key := 'test:ts:get:empty'.
	stick endpoint tsCreate: key.
	self assert: (stick endpoint tsGet: key) isNil
]

{ #category : 'tests' }
RsTsTest >> testTsGetLatestSample [
	| key result |
	key := 'test:ts:get:latest'.
	stick endpoint tsAdd: key timestamp: 1000 value: 12.
	stick endpoint tsAdd: key timestamp: 2000 value: 16.

	result := stick endpoint tsGet: key.
	self assert: result key equals: 2000.
	self assert: result value equals: 16
]

{ #category : 'tests' }
RsTsTest >> testTsGetNonExistingKey [
	self assert: (stick endpoint tsGet: 'test:ts:get:nonexisting') isNil
]

{ #category : 'tests' }
RsTsTest >> testTsRangeBasic [
	| key result |
	key := 'test:ts:range:basic'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRange: key rangeBy: [ :r | r all ] using: nil.
	self assert: result size equals: 3.
	self assert: (result at: 1) key equals: 1000.
	self assert: (result at: 1) value equals: 30.
	self assert: (result at: 3) value equals: 40
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithExplicitFromTo [
	| key result |
	key := 'test:ts:range:explicit'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r from: 1000 to: 1010 ]
		using: nil.
	self assert: result size equals: 2.
	self assert: (result at: 2) key equals: 1010
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithAssociationRangeBlock [
	| key result |
	key := 'test:ts:range:association'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.

	result := stick endpoint tsRange: key rangeBy: [ :r | 1000 -> r end ] using: nil.
	self assert: result size equals: 2
]

{ #category : 'tests' }
RsTsTest >> testTsRangeEmptySeriesReturnsEmptyArray [
	| key result |
	key := 'test:ts:range:empty'.
	stick endpoint tsCreate: key.
	result := stick endpoint tsRange: key rangeBy: [ :r | r all ] using: nil.
	self assertCollection: result equals: #()
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithFilterByValueAndCount [
	| key result |
	key := 'test:ts:range:filters'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 9999.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		using: [ :opts | opts filterByValueMin: -100 max: 100 ].
	self assert: result size equals: 2.
	self assert: (result at: 1) value equals: 30.
	self assert: (result at: 2) value equals: 40
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithSingleAggregator [
	| key result |
	key := 'test:ts:range:agg:single'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 1010 value: 110.
	stick endpoint tsAdd: key timestamp: 1020 value: 120.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts | aggs min; bucketDuration: 20 ]
		using: nil.
	self assert: result size equals: 2.
	self assert: (result at: 1) value equals: 100.
	self assert: (result at: 2) value equals: 120
]

{ #category : 'tests' }
RsTsTest >> testTsRangeWithMultipleAggregators [
	| key result |
	key := 'test:ts:range:agg:multi'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts | aggs min; avg; max; bucketDuration: 1000 ]
		using: nil.
	self assert: result size equals: 1.
	self assert: (result at: 1) value size equals: 3.
	self assert: ((result at: 1) value at: 1) equals: 30.
	self assert: ((result at: 1) value at: 3) equals: 40
]

{ #category : 'tests' }
RsTsTest >> testTsRangeAggregationWithAlign [
	| key result |
	key := 'test:ts:range:agg:align'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 1010 value: 110.
	stick endpoint tsAdd: key timestamp: 1020 value: 120.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts |
			aggOpts align: 10.
			aggs min; bucketDuration: 20 ]
		using: nil.
	self assert: (result at: 1) key equals: 990
]

{ #category : 'tests' }
RsTsTest >> testTsRangeAggregationWithBucketTimestampAndEmpty [
	| key result |
	key := 'test:ts:range:agg:empty'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 3000 value: 300.

	result := stick endpoint
		tsRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts |
			aggOpts bucketTimestamp: '+'; empty.
			aggs sum; bucketDuration: 1000 ]
		using: nil.
	self assert: result size equals: 3.
	self assert: (result at: 2) value equals: 0
]

{ #category : 'tests' }
RsTsTest >> testTsRevRangeBasic [
	| key result |
	key := 'test:ts:revrange:basic'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint tsRevRange: key rangeBy: [ :r | r all ] using: nil.
	self assert: result size equals: 3.
	self assert: (result at: 1) key equals: 1020.
	self assert: (result at: 1) value equals: 40.
	self assert: (result at: 3) key equals: 1000
]

{ #category : 'tests' }
RsTsTest >> testTsRevRangeWithCountOption [
	| key result |
	key := 'test:ts:revrange:count'.
	stick endpoint tsAdd: key timestamp: 1000 value: 30.
	stick endpoint tsAdd: key timestamp: 1010 value: 35.
	stick endpoint tsAdd: key timestamp: 1020 value: 40.

	result := stick endpoint
		tsRevRange: key
		rangeBy: [ :r | r all ]
		using: [ :opts | opts count: 2 ].
	self assert: result size equals: 2.
	self assert: (result at: 1) key equals: 1020.
	self assert: (result at: 2) key equals: 1010
]

{ #category : 'tests' }
RsTsTest >> testTsRevRangeWithAggregation [
	| key result |
	key := 'test:ts:revrange:agg'.
	stick endpoint tsAdd: key timestamp: 1000 value: 100.
	stick endpoint tsAdd: key timestamp: 1010 value: 110.
	stick endpoint tsAdd: key timestamp: 1020 value: 120.

	result := stick endpoint
		tsRevRange: key
		rangeBy: [ :r | r all ]
		aggregationBy: [ :aggs :aggOpts | aggs max; bucketDuration: 20 ]
		using: nil.
	self assert: result size equals: 2.
	self assert: (result at: 1) value equals: 120.
	self assert: (result at: 2) value equals: 110
]

{ #category : 'helpers' }
RsTsTest >> labelsAsDictionary: aLabelsArray [
	"Converts the nested labels array returned by TS.INFO
	 (e.g. #(#('sensor_id' '2') #('area_id' '32'))) into a Dictionary."
	^ aLabelsArray
		inject: Dictionary new
		into: [ :dict :pair | dict at: pair first put: pair second; yourself ]
]
