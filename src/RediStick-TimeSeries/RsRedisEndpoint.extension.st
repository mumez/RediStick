Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAdd: key timestamp: tsMSecsOrDateTime value: value [
	^ self tsAdd: key timestamp: tsMSecsOrDateTime value: value using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAdd: key timestamp: tsMSecsOrDateTime value: value using: optionsBlock [
	| args options tsValue |
	tsValue := tsMSecsOrDateTime
		ifNil: [ '*' ]
		ifNotNil: [ tsMSecsOrDateTime asRediStickUnixTimestampMillis ].
	args := {
		        'TS.ADD'.
		        key.
		        tsValue.
		        value } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsTsAddOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
		self tsAppendLabelsFrom: options to: args ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAdd: key value: value [
	^ self tsAdd: key timestamp: nil value: value
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAdd: key value: value using: optionsBlock [
	^ self tsAdd: key timestamp: nil value: value using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsCreate: key [
	^ self tsCreate: key using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsCreate: key using: optionsBlock [
	| args options |
	args := {
		        'TS.CREATE'.
		        key } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsTsCreateOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
		self tsAppendLabelsFrom: options to: args ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDel: key from: fromTimestamp to: toTimestamp [
	^ self
		unifiedCommand: {
				'TS.DEL'.
				key.
				fromTimestamp asRediStickUnixTimestampMillis.
				toTimestamp asRediStickUnixTimestampMillis }
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsGet: key [
	^ self tsGet: key latest: false
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsGet: key latest: aBoolean [
	| args result |
	args := {
		        'TS.GET'.
		        key } asOrderedCollection.
	aBoolean ifTrue: [ args add: 'LATEST' ].
	result := self unifiedCommand: args.
	^ (result isNil or: [ result isEmpty ])
		ifTrue: [ nil ]
		ifFalse: [ result first -> (self tsParseValue: result second) ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsInfo: key [
	"Returns a Dictionary of TS.INFO fields for the given time series key,
	 or nil if the key does not exist. Numeric fields are parsed as Numbers;
	 the 'labels' field is kept as the nested array returned by Redis so
	 callers can map it to a Dictionary if needed."
	| result info |
	result := self unifiedCommand: { 'TS.INFO'. key }.
	result ifNil: [ ^ nil ].
	info := Dictionary new.
	1 to: result size by: 2 do: [ :i |
		info at: (result at: i) put: (self tsParseValue: (result at: i + 1)) ].
	^ info
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock using: optionsBlock [
	| range options args |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	args := self
		tsRangeArgsFor: 'TS.RANGE'
		key: key
		range: range
		options: options
		aggregation: nil
		aggOptions: nil.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
	| range options args aggregation aggOptions |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	aggregation := RsTsAggregation new.
	aggOptions := RsTsAggregationOptions new.
	aggregationBlock value: aggregation value: aggOptions.
	args := self
		tsRangeArgsFor: 'TS.RANGE'
		key: key
		range: range
		options: options
		aggregation: aggregation
		aggOptions: aggOptions.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock using: optionsBlock [
	| range options args |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	args := self
		tsRangeArgsFor: 'TS.REVRANGE'
		key: key
		range: range
		options: options
		aggregation: nil
		aggOptions: nil.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
	| range options args aggregation aggOptions |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	options := nil.
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	aggregation := RsTsAggregation new.
	aggOptions := RsTsAggregationOptions new.
	aggregationBlock value: aggregation value: aggOptions.
	args := self
		tsRangeArgsFor: 'TS.REVRANGE'
		key: key
		range: range
		options: options
		aggregation: aggregation
		aggOptions: aggOptions.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsRangeFrom: rangeBlockResult [
	(rangeBlockResult isKindOf: RsTsRange) ifTrue: [ ^ rangeBlockResult ].
	^ RsTsRange from: rangeBlockResult key to: rangeBlockResult value
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsRangeArgsFor: cmdName key: key range: aTsRange options: options aggregation: aggregation aggOptions: aggOptions [
	| args |
	args := OrderedCollection new.
	args add: cmdName; add: key.
	args addAll: aTsRange asArray.
	options ifNotNil: [ args addAll: options asArray ].
	aggOptions ifNotNil: [ args addAll: aggOptions alignArray ].
	aggregation ifNotNil: [ args addAll: aggregation asArray ].
	aggOptions ifNotNil: [ args addAll: aggOptions tailArray ].
	^ args asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseRangeSamples: rawResult [
	rawResult ifNil: [ ^ #() ].
	^ (rawResult collect: [ :row |
		row size = 2
			ifTrue: [ row first -> (self tsParseValue: row second) ]
			ifFalse: [ row first -> ((row allButFirst) collect: [ :v | self tsParseValue: v ]) ] ])
		asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsAppendLabelsFrom: options to: args [
	options labels ifNotNil: [ :labels |
		args add: 'LABELS'.
		args addAll: (self flattenedKeysAndValuesFrom: labels) ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsParseValue: aValue [
	aValue isString ifFalse: [ ^ aValue ].
	^ NumberParser parse: aValue onError: [ aValue ]
]
