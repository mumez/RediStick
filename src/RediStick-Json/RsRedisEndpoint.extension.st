Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key options: options paths: paths [
	| args result |
	args := {
		        'JSON.GET'.
		        key } asOrderedCollection.
	options ifNotNil: [ args addAll: options asArray ].
	paths ifNotNil: [ args addAll: paths asArray ].
	result := self unifiedCommand: args.
	^ (options notNil and: [ options hasPrettyFormattingOptions ]) 
		ifTrue: [ result ]
		ifFalse: [ self safeParseJson: result ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key path: path [
	^ self jsonGet: key path: path using: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key paths: paths [
	^ self jsonGet: key paths: paths using: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key path: path using: optionsBlock [
	^ self jsonGet: key paths: {path} using: optionsBlock
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key paths: paths using: optionsBlock [
	| options |
	optionsBlock ifNotNil: [
		options := RsJsonGetOptions new.
		optionsBlock value: options.
	].
	^ self jsonGet: key options: options paths: paths
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonSet: key path: path value: value [
	^ self jsonSet: key path: path value: value options: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonSet: key path: path value: value options: options [
	| jsonString args |
	jsonString := self toJsonString: value.
	^ self jsonSet: key path: path rawValue: jsonString options: options
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonSet: key path: path rawValue: value options: options [
	| args |
	args := {
		        'JSON.SET'.
		        key.
		        path.
		        value } asOrderedCollection.
	options ifNotNil: [ args addAll: options asArray ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonSet: key path: path value: value using: optionsBlock [
	| options |
	options := RsJsonSetOptions new.
	optionsBlock value: options.
	^ self jsonSet: key path: path value: value options: options
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonObjKeys: key [
	^ self jsonObjKeys: key path: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonObjKeys: key path: path [
	| args result pathString |
	args := {
		        'JSON.OBJKEYS'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonObjLen: key [
	^ self jsonObjLen: key path: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonObjLen: key path: path [
	| args |
	args := {
		        'JSON.OBJLEN'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrLen: key [
	^ self jsonArrLen: key path: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrLen: key path: path [
	| args |
	args := {
		        'JSON.ARRLEN'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrAppend: key path: path values: values [
	| args jsonValues |
	args := {
		        'JSON.ARRAPPEND'.
		        key.
		        path asString } asOrderedCollection.
	jsonValues := values collect: [ :value | self toJsonString: value ].
	args addAll: jsonValues.
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrIndex: key path: path value: value [
	^ self jsonArrIndex: key path: path value: value using: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrIndex: key path: path value: value using: optionsBlock [
	| args options jsonValue |
	args := {
		        'JSON.ARRINDEX'.
		        key.
		        path asString } asOrderedCollection.
	jsonValue := self toJsonString: value.
	args add: jsonValue.
	optionsBlock ifNotNil: [
		options := RsJsonArrOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
	].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrIndex: key path: path value: value start: start [
	^ self jsonArrIndex: key path: path value: value using: [ :opts | opts start: start ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrIndex: key path: path value: value start: start stop: stop [
	^ self jsonArrIndex: key path: path value: value using: [ :opts | opts start: start; stop: stop ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrInsert: key path: path index: index value: value [
	^ self jsonArrInsert: key path: path index: index values: {value}
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrInsert: key path: path index: index values: values [
	| args jsonValues |
	args := {
		        'JSON.ARRINSERT'.
		        key.
		        path asString.
		        index } asOrderedCollection.
	jsonValues := values collect: [ :value | self toJsonString: value ].
	args addAll: jsonValues.
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrPop: key [
	^ self jsonArrPop: key path: SjJsonPath root
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrPop: key path: path [
	^ self jsonArrPop: key path: path using: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrPop: key path: path index: index [
	^ self jsonArrPop: key path: path using: [ :opts | opts index: index ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrPop: key path: path using: optionsBlock [
	| args options result |
	args := {
		        'JSON.ARRPOP'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	optionsBlock ifNotNil: [
		options := RsJsonArrOptions new.
		optionsBlock value: options.
		args addAll: options asArray.
	].
	result := self unifiedCommand: args.
	^ result
		ifNil: [ nil ]
		ifNotNil: [ (result collect: [:each | self safeParseJson: each]) asArray ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> safeParseJson: result [
	result ifNil: [ ^ result ].
	^ STONJSON fromString: result
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> toJsonString: value [
	^ STONJSON toString: value
]
