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
	(options notNil and: [ options hasPrettyFormattingOptions ]) 
		ifTrue: [ ^ result ].
	^ self buildGetResultFrom: (self safeParseJson: result) key: key paths: paths
]


{ #category : '*RediStick-Json' }
RsRedisEndpoint >> buildGetResultFrom: jsonArrayOrDict key: key paths: paths [
	"If result is nil (key doesn't exist), return invalid result"
	jsonArrayOrDict isNil ifTrue: [
		paths size = 1
			ifTrue: [^ RsJsonGetResult key: key path: paths first values: nil]
			ifFalse: [^ paths collect: [:eachPath | RsJsonGetResult key: key path: eachPath values: nil]]
	].

	"If one path, array will be returned"
	jsonArrayOrDict isArray ifTrue: [^ RsJsonGetResult key: key path: paths first values: jsonArrayOrDict].

	"If many paths, dict with path key will be returned"
	^ paths collect: [:eachPath | RsJsonGetResult key: key path: eachPath values: (jsonArrayOrDict at: eachPath asString)].
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
	| jsonString |
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
	| args |
	args := {
		        'JSON.OBJKEYS'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonObjLen: key [
	^ self jsonObjLen: key path: SjJsonPath root
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonObjLen: key path: path [
	| args result |
	args := {
		        'JSON.OBJLEN'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	result := self unifiedCommand: args.
	^ RsJsonGetResult key: key path: path values: result
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrLen: key [
	^ self jsonArrLen: key path: SjJsonPath root
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrLen: key path: path [
	| args result |
	args := {
		        'JSON.ARRLEN'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	result := self unifiedCommand: args.
	^ RsJsonGetResult key: key path: path values: result
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
	^ result ifNotNil: [ (result collect: [:each | self safeParseJson: each]) asArray ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonArrTrim: key path: path start: start stop: stop [
	| args result |
	args := {
		        'JSON.ARRTRIM'.
		        key.
		        path asString.
		        start.
		        stop } asOrderedCollection.
	result := self unifiedCommand: args.
	^ result asArray
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> safeParseJson: result [
	result ifNil: [ ^ result ].
	^ STONJSON fromString: result
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonStrLen: key [
	^ self jsonStrLen: key path: SjJsonPath root
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonStrLen: key path: path [
	| args result |
	args := {
		        'JSON.STRLEN'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	result := self unifiedCommand: args.
	^ RsJsonGetResult key: key path: path values: result
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonStrAppend: key value: value [
	^ self jsonStrAppend: key path: nil value: value
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonStrAppend: key path: path value: value [
	| args jsonValue |
	args := {
		        'JSON.STRAPPEND'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	jsonValue := self toJsonString: value.
	args add: jsonValue.
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonNumIncrBy: key path: path increment: increment [
	| args result |
	args := {
		        'JSON.NUMINCRBY'.
		        key.
		        path asString.
		        increment } asOrderedCollection.
	result := self unifiedCommand: args.
	^ result ifNotNil: [ self safeParseJson: result ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonNumMultBy: key path: path multiplier: multiplier [
	| args result |
	args := {
		        'JSON.NUMMULTBY'.
		        key.
		        path asString.
		        multiplier } asOrderedCollection.
	result := self unifiedCommand: args.
	^ result ifNotNil: [ self safeParseJson: result ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonDel: key [
	^ self jsonDel: key path: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonDel: key path: path [
	| args |
	args := {
		        'JSON.DEL'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonType: key [
	^ self jsonType: key path: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonType: key path: path [
	| args result |
	args := {
		        'JSON.TYPE'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	result := self unifiedCommand: args.
	^ path ifNil: [ result ] ifNotNil: [ result asArray ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonClear: key [
	^ self jsonClear: key path: nil
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonClear: key path: path [
	| args |
	args := {
		        'JSON.CLEAR'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonForget: key [
	^ self jsonDel: key
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonForget: key path: path [
	^ self jsonDel: key path: path
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonMerge: key path: path value: value [
	| args |
	args := {
		        'JSON.MERGE'.
		        key } asOrderedCollection.
	path ifNotNil: [ args add: path asString ].
	args add: (self toJsonString: value).
	^ self unifiedCommand: args.
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonToggle: key [
	^ self jsonToggle: key path: SjJsonPath root
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonToggle: key path: path [
	| rawResult |
	rawResult := self jsonToggleRaw: key path: path.
	^ rawResult ifNotNil: [ 
		rawResult collect: [ :each | 
			each ifNotNil: [ each = 1 ] ] ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonToggleRaw: key path: path [
	| args result |
	args := {
		        'JSON.TOGGLE'.
		        key.
		        path asString } asOrderedCollection.
	result := self unifiedCommand: args.
	^ result ifNil: [ nil ] ifNotNil: [ result asArray ]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonMSet: multiSetValues [
	| args |
	args := { 'JSON.MSET' } asOrderedCollection.
	multiSetValues params do: [ :triplet |
		args add: triplet first.                          "key"
		args add: triplet second asString.                "path"
		args add: (self toJsonString: triplet third) ].   "value"
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonMSetUsing: settingBlock [
	| multiSet |
	multiSet := RsJsonMultiSetValues new.
	settingBlock value: multiSet.
	^ self jsonMSet: multiSet
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonMGet: keys [
	"Get JSON values from multiple keys at root path"
	^ self jsonMGet: keys path: SjJsonPath root
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonMGet: keys path: path [
	"Get JSON values from specific path across multiple keys"
	| args pathStr results |
	args := OrderedCollection new.
	pathStr := path asString.
	args add: 'JSON.MGET'.
	args addAll: keys.
	args add: pathStr.
	results := self unifiedCommand: args asArray.
	^ keys with: results collect: [:key :result |
		| parsedResult |
		parsedResult := self safeParseJson: result.
		RsJsonGetResult key: key path: path values: parsedResult
	]
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> toJsonString: value [
	^ STONJSON toString: value
]
