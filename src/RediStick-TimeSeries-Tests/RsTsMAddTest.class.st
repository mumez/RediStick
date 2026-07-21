Class {
	#name : 'RsTsMAddTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddFromDictionary [
	| mv |
	mv := TsMultiValues fromDictionary: { 'test:ts:madd:dict:k1' -> 10. 'test:ts:madd:dict:k2' -> 20 } asDictionary.
	self assert: mv triplets size equals: 2.
	mv triplets do: [ :t | self assert: t second equals: '*' ]
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddFromKeyTimestampValues [
	| mv |
	mv := TsMultiValues fromKeyTimestampValues: {
		{ 'test:ts:madd:ktv:k1'. 1000. 10 }.
		{ 'test:ts:madd:ktv:k2'. 2000. 20 } }.
	self assert: mv triplets size equals: 2.
	self assert: mv triplets first second equals: 1000.
	self assert: mv triplets second second equals: 2000
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddFromKeyValues [
	| mv |
	mv := TsMultiValues fromKeyValues: { #('test:ts:madd:kv:k1' 10). #('test:ts:madd:kv:k2' 20) }.
	self assert: mv triplets size equals: 2.
	mv triplets do: [ :t | self assert: t second equals: '*' ]
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddMultipleTripletsDifferentKeys [
	| key1 key2 result |
	key1 := 'test:ts:madd:multi:k1'.
	key2 := 'test:ts:madd:multi:k2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	result := stick endpoint tsMAddUsing: [ :adder |
		adder key: key1 value: 10; key: key2 value: 20 ].
	self assert: result size equals: 2.
	result do: [ :ts | self assert: ts isNumber ].
	self assert: (stick endpoint tsGet: key1) value equals: 10.
	self assert: (stick endpoint tsGet: key2) value equals: 20
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddSameKeyMultipleSamples [
	| key result rangeResult |
	key := 'test:ts:madd:same'.
	stick endpoint tsCreate: key.
	result := stick endpoint tsMAdd: (TsMultiValues new
		key: key timestamp: 1000 value: 10;
		key: key timestamp: 2000 value: 20;
		yourself).
	self assert: result size equals: 2.
	self assert: result first equals: 1000.
	self assert: result second equals: 2000.
	rangeResult := stick endpoint tsRange: key rangeBy: [ :r | r all ] using: nil.
	self assert: rangeResult size equals: 2
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddSingleTripletExplicitTimestamp [
	| key result |
	key := 'test:ts:madd:explicit'.
	stick endpoint tsCreate: key.
	result := stick endpoint tsMAdd: (TsMultiValues new key: key timestamp: 1000 value: 42; yourself).
	self assert: result size equals: 1.
	self assert: result first equals: 1000
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddSingleTripletImplicitTimestamp [
	| key result |
	key := 'test:ts:madd:implicit'.
	stick endpoint tsCreate: key.
	result := stick endpoint tsMAdd: (TsMultiValues new key: key value: 27; yourself).
	self assert: result size equals: 1.
	self assert: result first isNumber.
	self assert: (stick endpoint tsGet: key) value equals: 27
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddUsingFluent [
	| key1 key2 result |
	key1 := 'test:ts:madd:fluent:k1'.
	key2 := 'test:ts:madd:fluent:k2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	result := stick endpoint tsMAddUsing: [ :adder |
		adder
			key: key1 value: 100;
			key: key2 value: 200 ].
	self assert: result size equals: 2.
	result do: [ :ts | self assert: ts isNumber ]
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddWithDateTimeTimestamp [
	| key now result |
	key := 'test:ts:madd:datetime'.
	stick endpoint tsCreate: key.
	now := DateAndTime now.
	result := stick endpoint tsMAdd: (TsMultiValues new key: key timestamp: now value: 55; yourself).
	self assert: result first equals: now asRediStickUnixTimestampMillis
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddWithDictionary [
	| key1 key2 result |
	key1 := 'test:ts:madd:withdict:k1'.
	key2 := 'test:ts:madd:withdict:k2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	result := stick endpoint tsMAddWithDictionary: { key1 -> 10. key2 -> 20 } asDictionary.
	self assert: result size equals: 2.
	result do: [ :ts | self assert: ts isNumber ]
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddWithKeyTimestampValues [
	| key1 key2 result |
	key1 := 'test:ts:madd:withktv:k1'.
	key2 := 'test:ts:madd:withktv:k2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	result := stick endpoint tsMAddWithKeyTimestampValues: {
		{ key1. 1000. 10 }.
		{ key2. 2000. 20 } }.
	self assert: result size equals: 2.
	self assert: result first equals: 1000.
	self assert: result second equals: 2000
]

{ #category : 'tests' }
RsTsMAddTest >> testTsMAddWithKeyValues [
	| key1 key2 result |
	key1 := 'test:ts:madd:withkv:k1'.
	key2 := 'test:ts:madd:withkv:k2'.
	stick endpoint tsCreate: key1.
	stick endpoint tsCreate: key2.
	result := stick endpoint tsMAddWithKeyValues: { { key1. 10 }. { key2. 20 } }.
	self assert: result size equals: 2.
	result do: [ :ts | self assert: ts isNumber ]
]
