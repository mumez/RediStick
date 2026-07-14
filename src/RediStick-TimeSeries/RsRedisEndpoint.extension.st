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
