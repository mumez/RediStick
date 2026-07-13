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
	| key result |
	key := 'test:ts:add:labels'.
	result := stick endpoint
		tsAdd: key
		timestamp: 1000
		value: 30
		using: [ :opts | opts labels: { 'sensor_id' -> '2'. 'area_id' -> '32' } ].
	self assert: result equals: 1000.
	self assert: (stick endpoint tsGet: key) key equals: 1000
]

{ #category : 'tests' }
RsTsTest >> testTsAddWithDateAndTime [
	| key now result |
	key := 'test:ts:add:datetime'.
	now := DateAndTime now.
	result := stick endpoint tsAdd: key timestamp: now value: 42.
	self assert: result equals: now asUnixTimestampValue
]

{ #category : 'tests' }
RsTsTest >> testTsAddWithExplicitTimestamp [
	| key result |
	key := 'test:ts:add:explicit'.
	result := stick endpoint tsAdd: key timestamp: 1000 value: 30.
	self assert: result equals: 1000
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
	| key result |
	key := 'test:ts:create:labels'.
	result := stick endpoint
		tsCreate: key
		using: [ :opts |
			opts
				retention: 60000;
				duplicatePolicy: 'MAX';
				labels: { 'sensor_id' -> '2'. 'area_id' -> '32' } ].
	self assert: result equals: 'OK'
]

{ #category : 'tests' }
RsTsTest >> testTsCreateWithOptions [
	| key result |
	key := 'test:ts:create:options'.
	result := stick endpoint
		tsCreate: key
		using: [ :opts |
			opts
				retention: 60000;
				encoding: 'COMPRESSED';
				chunkSize: 4096 ].
	self assert: result equals: 'OK'
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
	self
		should: [ stick endpoint tsGet: 'test:ts:get:nonexisting' ]
		raise: Error
]
