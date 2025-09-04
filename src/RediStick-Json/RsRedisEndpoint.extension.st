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
RsRedisEndpoint >> safeParseJson: result [
	result ifNil: [ ^ result ].
	^ STONJSON fromString: result
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> toJsonString: value [
	^ STONJSON toString: value
]
