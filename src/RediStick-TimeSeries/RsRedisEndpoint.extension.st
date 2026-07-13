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
		ifNotNil: [ tsMSecsOrDateTime asUnixTimestampValue ].
	args := {
		        'TS.ADD'.
		        key.
		        tsValue.
		        value } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsTsAddOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
		options labels ifNotNil: [ :labels |
			args add: 'LABELS'.
			args addAll: (self flattenedKeysAndValuesFrom: labels) ]
	].
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
		options labels ifNotNil: [ :labels |
			args add: 'LABELS'.
			args addAll: (self flattenedKeysAndValuesFrom: labels) ]
	].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-TimeSeries' }
RsRedisEndpoint >> tsDel: key from: fromTimestamp to: toTimestamp [
	^ self
		unifiedCommand: {
				'TS.DEL'.
				key.
				fromTimestamp asUnixTimestampValue.
				toTimestamp asUnixTimestampValue }
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
RsRedisEndpoint >> tsParseValue: aValue [
	aValue isString ifFalse: [ ^ aValue ].
	^ NumberParser parse: aValue onError: [ aValue ]
]
