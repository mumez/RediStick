Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCall: functionName [
	^ self fCall: functionName keys: #() args: #()
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCall: functionName args: args [
	^ self fCall: functionName keys: #() args: args
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCall: functionName keys: keys [
	^ self fCall: functionName keys: keys args: #()
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCall: functionName keys: keys args: args [
	^ self fCall: functionName command: 'FCALL' keys: keys args: args
]

{ #category : '*RediStick-Function-private' }
RsRedisEndpoint >> fCall: functionName command: commandName keys: keys args: args [
	| cmdArgs keysColl argsColl |
	keysColl := keys
		ifNil: [ #() ]
		ifNotNil: [
			(keys isString or: [ keys isCollection not ])
				ifTrue: [ Array with: keys ]
				ifFalse: [ keys asArray ] ].
	argsColl := args
		ifNil: [ #() ]
		ifNotNil: [
			(args isString or: [ args isCollection not ])
				ifTrue: [ Array with: args ]
				ifFalse: [ args asArray ] ].
	cmdArgs := OrderedCollection new.
	cmdArgs add: commandName.
	cmdArgs add: functionName.
	cmdArgs add: keysColl size.
	cmdArgs addAll: keysColl.
	cmdArgs addAll: argsColl.
	^ self unifiedCommand: cmdArgs
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCallRo: functionName [
	^ self fCallRo: functionName keys: #() args: #()
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCallRo: functionName args: args [
	^ self fCallRo: functionName keys: #() args: args
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCallRo: functionName keys: keys [
	^ self fCallRo: functionName keys: keys args: #()
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> fCallRo: functionName keys: keys args: args [
	^ self fCall: functionName command: 'FCALL_RO' keys: keys args: args
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionDelete: libraryName [
	^ self unifiedCommand: { 'FUNCTION'. 'DELETE'. libraryName }
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionList [
	^ self functionListUsing: nil
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionList: libraryPattern [
	^ self functionListUsing: [ :opts | opts libraryName: libraryPattern ]
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionList: libraryPattern withCode: aBoolean [
	^ self functionListUsing: [ :opts |
		opts libraryName: libraryPattern.
		opts withCode: aBoolean ]
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionListUsing: optionsBlock [
	| args options rawList |
	args := { 'FUNCTION'. 'LIST' } asOrderedCollection.
	optionsBlock ifNotNil: [
		options := RsFunctionListOptions new.
		optionsBlock value: options.
		args addAll: options asArray ].
	rawList := self unifiedCommand: args.
	rawList ifNil: [ ^ #() ].
	^ rawList collect: [ :each | RsFunctionLibraryInfo fromArrayOrDictionary: each ]
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionLoad: code [
	^ self functionLoad: code replace: false
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionLoad: code replace: aBoolean [
	| normalizedCode args |
	normalizedCode := code copyReplaceAll: String cr with: String lf.
	args := OrderedCollection new.
	args add: 'FUNCTION'.
	args add: 'LOAD'.
	aBoolean ifTrue: [ args add: 'REPLACE' ].
	args add: normalizedCode.
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionFlush [
	^ self unifiedCommand: { 'FUNCTION'. 'FLUSH' }
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionFlushAsync [
	^ self functionFlush: 'ASYNC'
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionFlushSync [
	^ self functionFlush: 'SYNC'
]

{ #category : '*RediStick-Function-private' }
RsRedisEndpoint >> functionFlush: aMode [
	^ self unifiedCommand: { 'FUNCTION'. 'FLUSH'. aMode }
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionKill [
	^ self unifiedCommand: { 'FUNCTION'. 'KILL' }
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionStats [
	^ RsFunctionStats fromArrayOrDictionary: (self unifiedCommand: { 'FUNCTION'. 'STATS' })
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionDump [
	^ self rawUnifiedCommand: { 'FUNCTION'. 'DUMP' }
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionRestore: payload [
	^ self functionRestore: payload mode: nil
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionRestore: payload mode: aPolicyString [
	| args |
	args := OrderedCollection new.
	args add: 'FUNCTION'.
	args add: 'RESTORE'.
	args add: payload.
	aPolicyString ifNotNil: [ args add: aPolicyString ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Function' }
RsRedisEndpoint >> functionRestore: payload using: optionsBlock [
	| options args |
	options := RsFunctionRestoreOptions new.
	optionsBlock value: options.
	args := OrderedCollection new.
	args add: 'FUNCTION'.
	args add: 'RESTORE'.
	args add: payload.
	args addAll: options asArray.
	^ self unifiedCommand: args
]
