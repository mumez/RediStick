Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAlter: key chunkSize: aSize [
	^ self tsAlter: key using: [ :opts | opts chunkSize: aSize ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAlter: key duplicatePolicy: aPolicy [
	^ self tsAlter: key using: [ :opts | opts duplicatePolicy: aPolicy ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAlter: key labels: labelsAssoc [
	^ self tsAlter: key using: [ :opts | opts labels: labelsAssoc ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAlter: key retention: aRetentionMs [
	^ self tsAlter: key using: [ :opts | opts retention: aRetentionMs ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsAlter: key using: optionsBlock [
	| args options |
	args := {
		        'TS.ALTER'.
		        key } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsTsAlterOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
		self tsAppendLabelsFrom: options to: args ].
	^ self unifiedCommand: args
]

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
	| result info |
	result := self unifiedCommand: { 'TS.INFO'. key }.
	result ifNil: [ ^ nil ].
	info := Dictionary new.
	1 to: result size by: 2 do: [ :i |
		info at: (result at: i) put: (self tsParseValue: (result at: i + 1)) ].
	^ info
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock [
	^ self tsRange: key rangeBy: rangeBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock using: optionsBlock [
	^ self tsExecuteRange: 'TS.RANGE' key: key rangeBy: rangeBlock aggregationBy: nil using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock [
	^ self tsRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
	^ self tsExecuteRange: 'TS.RANGE' key: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock [
	^ self tsRevRange: key rangeBy: rangeBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock using: optionsBlock [
	^ self tsExecuteRange: 'TS.REVRANGE' key: key rangeBy: rangeBlock aggregationBy: nil using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock [
	^ self tsRevRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsRevRange: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
	^ self tsExecuteRange: 'TS.REVRANGE' key: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsIncrBy: key increment: addend [
	^ self tsIncrBy: key timestamp: nil increment: addend using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsIncrBy: key increment: addend using: optionsBlock [
	^ self tsIncrBy: key timestamp: nil increment: addend using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsIncrBy: key timestamp: tsMSecsOrDateTime increment: addend [
	^ self tsIncrBy: key timestamp: tsMSecsOrDateTime increment: addend using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsIncrBy: key timestamp: tsMSecsOrDateTime increment: addend using: optionsBlock [
	^ self tsIncrOrDecr: 'TS.INCRBY' key: key timestamp: tsMSecsOrDateTime value: addend using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDecrBy: key decrement: subtrahend [
	^ self tsDecrBy: key timestamp: nil decrement: subtrahend using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDecrBy: key decrement: subtrahend using: optionsBlock [
	^ self tsDecrBy: key timestamp: nil decrement: subtrahend using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDecrBy: key timestamp: tsMSecsOrDateTime decrement: subtrahend [
	^ self tsDecrBy: key timestamp: tsMSecsOrDateTime decrement: subtrahend using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDecrBy: key timestamp: tsMSecsOrDateTime decrement: subtrahend using: optionsBlock [
	^ self tsIncrOrDecr: 'TS.DECRBY' key: key timestamp: tsMSecsOrDateTime value: subtrahend using: optionsBlock
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsIncrOrDecr: cmdName key: key timestamp: tsMSecsOrDateTimeOrNil value: aValue using: optionsBlock [
	"private"
	| args options |
	args := { cmdName. key. aValue } asOrderedCollection.
	tsMSecsOrDateTimeOrNil ifNotNil: [ :ts |
		args addAll: { 'TIMESTAMP'. ts asRediStickUnixTimestampMillis } ].
	optionsBlock ifNotNil: [
		options := RsTsAlterOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
		self tsAppendLabelsFrom: options to: args ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsExecuteRange: cmdName key: key rangeBy: rangeBlock aggregationBy: aggregationBlock using: optionsBlock [
    "private"
    | range options aggregation aggOptions args |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	optionsBlock ifNotNil: [
		options := RsTsRangeOptions new.
		optionsBlock value: options ].
	aggregationBlock ifNotNil: [
		aggregation := RsTsAggregation new.
		aggOptions := RsTsAggregationOptions new.
		aggregationBlock cull: aggregation cull: aggOptions ].
	args := self
		tsRangeArgsFor: cmdName key: key
		range: range options: options
		aggregation: aggregation aggOptions: aggOptions.
	^ self tsParseRangeSamples: (self unifiedCommand: args)
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsRangeFrom: rangeBlockResult [
    "private"
	rangeBlockResult isAssociation ifTrue: [
		^ RsTsRange from: rangeBlockResult key to: rangeBlockResult value ].
	^ rangeBlockResult
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsRangeArgsFor: cmdName key: key range: aTsRange options: options aggregation: aggregation aggOptions: aggOptions [
	"private"
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
    "private"
	rawResult ifNil: [ ^ #() ].
	^ (rawResult collect: [ :row |
		row size = 2
			ifTrue: [ row first -> (self tsParseValue: row second) ]
			ifFalse: [ row first -> ((row allButFirst) collect: [ :v | self tsParseValue: v ]) ] ])
		asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsAppendLabelsFrom: options to: args [
    "private"
	options labels ifNotNil: [ :labels |
		args add: 'LABELS'.
		args addAll: (self flattenedKeysAndValuesFrom: labels) ]
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseValue: aValue [
    "private"
	aValue isString ifFalse: [ ^ aValue ].
	^ NumberParser parse: aValue onError: [ aValue ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMAdd: tsMultiValues [
	| args |
	args := { 'TS.MADD' } asOrderedCollection.
	args addAll: tsMultiValues triplets flattened.
	^ self unifiedCommand: args
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMAddUsing: tsMultiValuesAddingBlock [
	| multiAdd |
	multiAdd := TsMultiValues new.
	tsMultiValuesAddingBlock value: multiAdd.
	^ self tsMAdd: multiAdd
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMAddWithDictionary: aDictionary [
	^ self tsMAdd: (TsMultiValues fromDictionary: aDictionary)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMAddWithKeyTimestampValues: aCollection [
	^ self tsMAdd: (TsMultiValues fromKeyTimestampValues: aCollection)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMAddWithKeyValues: aCollection [
	^ self tsMAdd: (TsMultiValues fromKeyValues: aCollection)
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsCreateRule: sourceKey dest: destKey aggregationBy: aggregationBlock [
	^ self tsCreateRule: sourceKey dest: destKey aggregationBy: aggregationBlock alignTimestamp: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsCreateRule: sourceKey dest: destKey aggregationBy: aggregationBlock alignTimestamp: tsMSecsOrDateTimeOrNil [
	| args aggregation |
	args := { 'TS.CREATERULE'. sourceKey. destKey } asOrderedCollection.
	aggregation := RsTsAggregation forSingle.
	aggregationBlock value: aggregation.
	args addAll: aggregation asArray.
	tsMSecsOrDateTimeOrNil ifNotNil: [ :ts |
		args add: ts asRediStickUnixTimestampMillis ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDeleteRule: sourceKey dest: destKey [
	^ self unifiedCommand: { 'TS.DELETERULE'. sourceKey. destKey }
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsQueryIndexFilterBy: filterBlock [
	| builder args |
	builder := RsTsFilterBuilder new.
	filterBlock value: builder.
	builder filters ifEmpty: [ Error signal: 'At least one filter expression is required' ].
	args := { 'TS.QUERYINDEX' } asOrderedCollection.
	args addAll: (builder filters collect: [ :f | f asString ]).
	^ (self unifiedCommand: args asArray) ifNil: [ #() ] ifNotNil: [ :r | r asArray ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMGetFilterBy: filterBlock [
	^ self tsMGetFilterBy: filterBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMGetFilterBy: filterBlock using: optionsBlock [
	| builder options args result |
	builder := RsTsFilterBuilder new.
	filterBlock value: builder.
	builder filters ifEmpty: [ Error signal: 'At least one filter expression is required' ].
	options := RsTsMGetOptions new.
	optionsBlock ifNotNil: [ optionsBlock value: options ].
	args := { 'TS.MGET' } asOrderedCollection.
	args addAll: options asArray.
	args add: 'FILTER'.
	args addAll: (builder filters collect: [ :f | f asString ]).
	result := self unifiedCommand: args asArray.
	^ self tsParseMGetResult: result
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseMGetResult: rawResult [
	"private"
	rawResult ifNil: [ ^ #() ].
	^ (rawResult collect: [ :row | self tsValueFromMGetRow: row ]) asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsValueFromMGetRow: row [
	"private"
	| key labelsPairs sample |
	key := row first.
	labelsPairs := row second.
	sample := row third.
	^ RsTsValue
		key: key
		timestamp: sample first
		value: (self tsParseValue: sample second)
		labels: (self tsLabelsDictionaryFrom: labelsPairs)
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsLabelsDictionaryFrom: labelsPairs [
	^ labelsPairs
		inject: Dictionary new
		into: [ :dict :pair | dict at: pair first put: pair second; yourself ]
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRangeBy: rangeBlock filterBy: filterBlock [
	^ self
		tsExecuteMRange: 'TS.MRANGE'
		rangeBy: rangeBlock
		filterBy: filterBlock
		aggregationBy: nil
		groupBy: nil
		using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock [
	^ self tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: optionsBlock [
	^ self
		tsExecuteMRange: 'TS.MRANGE'
		rangeBy: rangeBlock
		filterBy: filterBlock
		aggregationBy: aggregationBlock
		groupBy: nil
		using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock [
	^ self tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock [
	^ self
		tsExecuteMRange: 'TS.MRANGE'
		rangeBy: rangeBlock
		filterBy: filterBlock
		aggregationBy: aggregationBlock
		groupBy: groupingBlock
		using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRevRangeBy: rangeBlock filterBy: filterBlock [
	^ self
		tsExecuteMRange: 'TS.MREVRANGE'
		rangeBy: rangeBlock
		filterBy: filterBlock
		aggregationBy: nil
		groupBy: nil
		using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock [
	^ self tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock using: optionsBlock [
	^ self
		tsExecuteMRange: 'TS.MREVRANGE'
		rangeBy: rangeBlock
		filterBy: filterBlock
		aggregationBy: aggregationBlock
		groupBy: nil
		using: optionsBlock
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock [
	^ self tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: nil
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsMRevRangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock [
	^ self
		tsExecuteMRange: 'TS.MREVRANGE'
		rangeBy: rangeBlock
		filterBy: filterBlock
		aggregationBy: aggregationBlock
		groupBy: groupingBlock
		using: optionsBlock
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsExecuteMRange: cmdName rangeBy: rangeBlock filterBy: filterBlock aggregationBy: aggregationBlock groupBy: groupingBlock using: optionsBlock [
	"private"
	| range builder options aggregation aggOptions groupBy |
	range := self tsRangeFrom: (rangeBlock value: RsTsRange).
	builder := RsTsFilterBuilder new.
	filterBlock value: builder.
	builder filters ifEmpty: [ Error signal: 'At least one filter expression is required' ].
	optionsBlock ifNotNil: [
		options := RsTsMRangeOptions new.
		optionsBlock value: options ].
	aggregationBlock ifNotNil: [
		aggregation := RsTsAggregation new.
		aggOptions := RsTsAggregationOptions new.
		aggregationBlock cull: aggregation cull: aggOptions ].
	groupingBlock ifNotNil: [
		groupBy := RsTsGroupBy new.
		groupingBlock value: groupBy ].
	^ self
		tsParseMRangeResult: (self unifiedCommand: (self
			tsMRangeArgsFor: cmdName range: range options: options
			aggregation: aggregation aggOptions: aggOptions
			filterBuilder: builder groupBy: groupBy))
		groupBy: groupBy
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsMRangeArgsFor: cmdName range: range options: options aggregation: aggregation aggOptions: aggOptions filterBuilder: builder groupBy: groupBy [
	"private"
	| args |
	args := OrderedCollection new.
	args add: cmdName.
	args addAll: range asArray.
	options ifNotNil: [ args addAll: options asArray ].
	groupBy ifNotNil: [
		(options isNil or: [ options isWithLabels not and: [ options selectedLabels isNil ] ])
			ifTrue: [ args add: 'WITHLABELS' ] ].
	aggOptions ifNotNil: [ args addAll: aggOptions alignArray ].
	aggregation ifNotNil: [ args addAll: aggregation asArray ].
	aggOptions ifNotNil: [ args addAll: aggOptions tailArray ].
	args add: 'FILTER'.
	args addAll: (builder filters collect: [ :f | f asString ]).
	groupBy ifNotNil: [ args addAll: groupBy asArray ].
	^ args asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseMRangeResult: rawResult groupBy: groupBy [
	"private"
	rawResult ifNil: [ ^ #() ].
	^ (rawResult collect: [ :row |
		groupBy
			ifNil: [ self tsParseRangeRow: row ]
			ifNotNil: [ self tsParseGroupedRangeRow: row groupBy: groupBy ] ]) asArray
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseRangeRow: row [
	"private"
	^ RsTsRangeValue
		key: row first
		labels: (self tsLabelsDictionaryFrom: row second)
		values: (self tsParseRangeSamples: row third)
]

{ #category : '*RediStick-TimeSeries-private' }
RsRedisEndpoint >> tsParseGroupedRangeRow: row groupBy: groupBy [
	"private"
	| labelsDict |
	labelsDict := self tsLabelsDictionaryFrom: row second.
	^ RsTsGroupedRangeValue
		key: row first
		labels: labelsDict
		groupByLabel: groupBy label -> (labelsDict at: groupBy label ifAbsent: [ nil ])
		reducer: (labelsDict at: '__reducer__' ifAbsent: [ nil ])
		sourceKeys: ((labelsDict at: '__source__' ifAbsent: [ '' ]) substrings: ',') asArray
		values: (self tsParseRangeSamples: row third)
]
