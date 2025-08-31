Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key options: options paths: paths [
	| args |
	args := {
		        'JSON.GET'.
		        key } asOrderedCollection.
	options ifNotNil: [ args addAll: options asArray ].
	paths ifNotNil: [ args addAll: paths asArray ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Json' }
RsRedisEndpoint >> jsonGet: key path: path [
	^ self jsonGet: key path: path using: nil
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
