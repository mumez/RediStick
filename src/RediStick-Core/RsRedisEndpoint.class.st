Class {
	#name : 'RsRedisEndpoint',
	#superclass : 'SkSyncStickEndpoint',
	#instVars : [
		'pubsub',
		'channels',
		'subscriptionMode',
		'timeout',
		'listener',
		'sendMutex'
	],
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'transactions' }
RsRedisEndpoint >> atomic: aBlock [ 
	self multi.
	aBlock value.
	^ self exec
]

{ #category : 'transactions' }
RsRedisEndpoint >> atomic: aBlock watch: keys [ 
	self watch: keys.
	self multi.
	aBlock value.
	^ self exec
]

{ #category : 'commands-connection' }
RsRedisEndpoint >> auth: password [
	^ self
		unifiedCommand:
			{'AUTH'.
			password}
]

{ #category : 'commands-connection' }
RsRedisEndpoint >> auth: password user: userName [
	^ self
		unifiedCommand:
			{'AUTH'.
			userName.
			password}
]

{ #category : 'commands-server' }
RsRedisEndpoint >> beMaster [
	^ self inlineCommand: 'SLAVEOF no one'
]

{ #category : 'commands-server' }
RsRedisEndpoint >> bgRewriteAOF [
	^ self inlineCommand: 'BGREWRITEAOF'
]

{ #category : 'commands-server' }
RsRedisEndpoint >> bgSave [
	^ self inlineCommand: 'BGSAVE'
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> blPop: keys timeout: seconds [
	^ self unifiedCommand: {'BLPOP'} , keys , {seconds}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> brPop: keys timeout: seconds [
	^ self unifiedCommand: {'BRPOP'} , keys , {seconds}
]

{ #category : 'accessing' }
RsRedisEndpoint >> channels [
	^channels
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> dbSize [
	^ self inlineCommand: 'DBSIZE'
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> decr: aKey [
	| val |
	val := (self
		unifiedCommand:
			{'DECR'.
			aKey}).
	^val ifNotNil: [:v | v asNumber]
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> decr: aKey by: anInteger [
	| val |
	val :=  (self
		unifiedCommand:
			{'DECRBY'.
			aKey.
			anInteger}).
	^val ifNotNil: [:v | v asNumber]
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> del: keys [
	^ self unifiedCommand: {'DEL'} , keys
]

{ #category : 'commands-transactions' }
RsRedisEndpoint >> discard [
	^ self inlineCommand: 'DISCARD'
]

{ #category : 'private' }
RsRedisEndpoint >> enterPubsub [
	pubsub := true.
]

{ #category : 'private' }
RsRedisEndpoint >> errorHandlingDo: aBlock returning: returnBlock [
	^ [ aBlock value ]
		on: Error
		do: [ :ex | 
			(ex isKindOf: RsGenericError)
				ifTrue: [ self onRedisGenericErrorSignaled: ex ]
				ifFalse: [ self onErrorSignaled: ex ].
			returnBlock value ]
]

{ #category : 'commands-transactions' }
RsRedisEndpoint >> exec [
	^ self inlineCommand: 'EXEC'
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> exists: aKey [
	^ (self
		unifiedCommand:
			{'EXISTS'.
			aKey}) = 1
]

{ #category : 'private' }
RsRedisEndpoint >> exitPubsub [
	pubsub := false.
	listener := nil.
	
]

{ #category : 'commands-expiration' }
RsRedisEndpoint >> expire: aKey at: aDateAndTime [
	^ self
		unifiedCommand:
			{'EXPIREAT'.
			aKey.
			(aDateAndTime asUnixTime)}
]

{ #category : 'commands-expiration' }
RsRedisEndpoint >> expire: aKey seconds: seconds [
	^ self
		unifiedCommand:
			{'EXPIRE'.
			aKey.
			seconds}
]

{ #category : 'private' }
RsRedisEndpoint >> flattenedKeysAndValuesFrom: aDictionary [
	^ aDictionary associations gather: [ :each | {each key. each value} ]
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> flushAll [
	^ self inlineCommand: 'FLUSHALL'
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> flushDb [
	^ self inlineCommand: 'FLUSHDB'
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> get: aKey [
	^ self
		unifiedCommand:
			{'GET'.
			aKey}
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> getSet: aKey value: aValue [
	^ self
		unifiedCommand:
			{'GETSET'.
			aKey.
			aValue}
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hDel: aKey field: aField [ 
	^ self unifiedCommand: {'HDEL' . aKey. aField}
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hExists: aKey field: aField [ 
	^ (self unifiedCommand: {'HEXISTS' . aKey. aField})
		= 1
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hGet: aKey field: aField [

	^ self unifiedCommand: {
			  'HGET'.
			  aKey.
			  aField }
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hGetAll: aKey [
	^ Dictionary
		newFromPairs:
			(self
				unifiedCommand:
					{'HGETALL'.
					aKey})
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hIncrBy: key field: field value: value [

	^ self unifiedCommand: {
			  'HINCRBY'.
			  key.
			  field.
			  value }
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hKeys: aKey [
	^ self
		unifiedCommand:
			{'HKEYS'.
			aKey}
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hLen: aKey [
	^ self
		unifiedCommand:
			{'HLEN'.
			aKey}
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hMGet: aKey fields: fields [

	^ self unifiedCommand: {
			  'HMGET'.
			  aKey } , fields
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hSet: key dictionary: aDict [

	^ self unifiedCommand: {
			  'HSET'.
			  key } , (self flattenedKeysAndValuesFrom: aDict)
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hSet: key field: field value: value [ 
	^ self unifiedCommand: {'HSET'. key. field. value}
]

{ #category : 'commands-hashes' }
RsRedisEndpoint >> hVals: aKey [
	^ self
		unifiedCommand:
			{'HVALS'.
			aKey}
]

{ #category : 'private' }
RsRedisEndpoint >> handlePubsubMessage: rawMessageArray callback: aBlock [
	| message |
	message := RsPubsubMessage fromRawMessageArray: rawMessageArray.
	aBlock value: message.
	((message isUnsubscribe)and: [ message numberOfChannels = 0 ])
		ifTrue: [ self exitPubsub ]
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> incr: aKey [
	| val |
	val := (self
		unifiedCommand:
			{'INCR'.
			aKey}).
	^val ifNotNil: [ :v | v  asNumber]
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> incr: aKey by: anInteger [
	| val |
	val :=  (self
		unifiedCommand:
			{'INCRBY'.
			aKey.
			anInteger}).
	^val ifNotNil: [ :v | v  asNumber]
]

{ #category : 'commands-connection' }
RsRedisEndpoint >> info [
	^ self unifiedCommand: {'INFO'}
]

{ #category : 'initialize-release' }
RsRedisEndpoint >> initialize [
	super initialize.
	pubsub := false.
	timeout := 30
]

{ #category : 'private commands' }
RsRedisEndpoint >> inlineCommand: aCommandString [
	| received |
	received := nil.
	self sendMutex
		critical: [ self
				errorHandlingDo: [ self writeString: aCommandString.
					pubsub ifFalse: [ received := self parseReply ] ].
			received ifNotNil: [ self onDataReceived: received ] ].
	^ received
]

{ #category : 'testing' }
RsRedisEndpoint >> isConnected [
	^self socketStream notNil and: [ self socketStream isConnected ]
]

{ #category : 'testing' }
RsRedisEndpoint >> isPubsub [
	^ subscriptionMode notNil
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> keys: aPattern [
	^ self
		unifiedCommand:
			{'KEYS'.
			aPattern}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lIndex: aKey value: aValue [
	^ self
		unifiedCommand:
			{'LINDEX'.
			aKey.
			aValue}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lInsert: aKey value: aValue after: pivot [
	^ self unifiedCommand: {
			  'LINSERT'.
			  aKey.
			  'AFTER'.
			  pivot.
			  aValue }
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lInsert: aKey value: aValue before: pivot [
	^ self unifiedCommand: {
			  'LINSERT'.
			  aKey.
			  'BEFORE'.
			  pivot.
			  aValue }
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lLen: aKey [
	^ self
		unifiedCommand:
			{'LLEN'.
			aKey}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lMoveFrom: source removing: srcFromRightOrLeft to: destination adding: destToRightOrLeft [
	| srcRightOrLeft destRightOrLeft |
	srcRightOrLeft := srcFromRightOrLeft
		                  ifNil: [ 'RIGHT' ]
		                  ifNotNil: [ srcFromRightOrLeft ]. "RIGHT or LEFT"
	destRightOrLeft := destToRightOrLeft
		                   ifNil: [ 'LEFT' ]
		                   ifNotNil: [ destToRightOrLeft ]. "RIGHT or LEFT"
	^ self unifiedCommand: {
			  'LMOVE'.
			  source.
			  destination.
			  srcRightOrLeft.
			  destRightOrLeft }
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lMoveFrom: source to: destination [
	^ self
		  lMoveFrom: source
		  removing: 'RIGHT'
		  to: destination
		  adding: 'LEFT'
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPop: aKey [
	^ self
		unifiedCommand:
			{'LPOP'.
			aKey}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPop: aKey count: count [
	^ self unifiedCommand: {
			  'LPOP'.
			  aKey.
			  count }
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPos: aKey value: value [
	^ self
		  lPos: aKey
		  value: value
		  rank: nil
		  count: nil
		  maxlen: nil
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPos: aKey value: value count: count [
	^ self
		  lPos: aKey
		  value: value
		  rank: nil
		  count: count
		  maxlen: nil
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPos: aKey value: value maxlen: maxlen [
	^ self
		  lPos: aKey
		  value: value
		  rank: nil
		  count: nil
		  maxlen: maxlen
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPos: aKey value: value rank: rank [
	^ self
		  lPos: aKey
		  value: value
		  rank: rank
		  count: nil
		  maxlen: nil
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPos: aKey value: value rank: rank count: count maxlen: maxlen [
	| args |
	args := {
		        'LPOS'.
		        aKey.
		        value } asOrderedCollection.
	rank ifNotNil: [
		args addAll: {
				'RANK'.
				rank } ].
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	maxlen ifNotNil: [
		args addAll: {
				'MAXLEN'.
				maxlen } ].

	^ self unifiedCommand: args
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPosBackward: aKey value: value maxlen: maxlen [
	^ self
		  lPos: aKey
		  value: value
		  rank: -1
		  count: nil
		  maxlen: maxlen
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPush: aKey value: aValue [ 
	^ self
		unifiedCommand: { 'LPUSH'
		. aKey
		. aValue}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lPushx: aKey value: aValue [ 
	^ self
		unifiedCommand: { 'LPUSHX'
		. aKey
		. aValue}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lRange: aKey start: startIndex end: endIndex [ 
	^ self unifiedCommand: {'LRANGE' . aKey. startIndex. endIndex}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lRem: aKey count: aCount value: aValue [ 
	^ self unifiedCommand: {'LREM' .aKey. aCount. aValue}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lSet: aKey index: anIndex value: aValue [ 
	^ self unifiedCommand: {'LSET' .aKey. anIndex. aValue}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> lTrim: aKey start: startIndex end: endIndex [ 
	^ self unifiedCommand: {'LTRIM'  .aKey. startIndex. endIndex}
]

{ #category : 'commands-server' }
RsRedisEndpoint >> lastSave [
	^ self inlineCommand: 'LASTSAVE'
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> mGet: keys [
	keys ifEmpty: [ ^#() ].
	^ self unifiedCommand: {'MGET'} , keys
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> mSet: aDictionary [
	^ self unifiedCommand: {'MSET'} , (self flattenedKeysAndValuesFrom: aDictionary )
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> mSetNx: aDictionary [
	^ self unifiedCommand: {'MSETNX'} , (self flattenedKeysAndValuesFrom: aDictionary)
]

{ #category : 'commands-server' }
RsRedisEndpoint >> monitor: aStream [ 
	self socketStream nextPutAll: 'MONITOR';
		 crlf;
		 flush.
	[[[self socketStream atEnd]
		whileFalse: [aStream
				nextPutAll: self parseSingleLine;
				nextPutAll: String crlf;
				flush]]
		on: Error
		do: [:ex | aStream nextPutAll: 'Connection Closed';
				 nextPutAll: String crlf;
				 flush]] fork
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> move: aKey to: zeroBasedDbIndex [
	^ self
		unifiedCommand:
			{'MOVE'.
			aKey.
			zeroBasedDbIndex}
]

{ #category : 'commands-transactions' }
RsRedisEndpoint >> multi [
	^ self inlineCommand: 'MULTI'
]

{ #category : 'private connection' }
RsRedisEndpoint >> onClosing [
	pubsub ifTrue: [self releasePubsub].
	super onClosing
	
]

{ #category : 'error handling' }
RsRedisEndpoint >> onRedisGenericErrorSignaled: aRsGenericError [
	self stick isReleased ifTrue: [^self].
	self logger error: aRsGenericError.
	self stick onRedisGenericErrorSignaled: aRsGenericError
]

{ #category : 'private replies' }
RsRedisEndpoint >> parseBulkReply [
	| length reply |
	length := self parseInteger.
	length = -1
		ifTrue: [ reply := nil ]
		ifFalse: [ 
			reply := self socketStream next: length.
			self socketStream next: 2 "skip separators"].
	^ self stringFromUtf8Bytes: reply
]

{ #category : 'private replies' }
RsRedisEndpoint >> parseError [
	| error |
	error := RsGenericError errorMessage: self parseSingleLine.
	error signal.
	^ nil
]

{ #category : 'private replies' }
RsRedisEndpoint >> parseInteger [
	^self parseSingleLine asInteger
]

{ #category : 'private replies' }
RsRedisEndpoint >> parseMultiBulkReply [
	| count reply |
	count := self parseInteger.
	count = -1
		ifTrue: [^ nil].
	reply := OrderedCollection new.
	count
		timesRepeat: [reply add: self parseReply].
	^ reply
]

{ #category : 'private replies' }
RsRedisEndpoint >> parseReply [
	| strm replyToken |
	strm := self socketStream ifNil: [ ^nil ].
	replyToken := [strm next] on: Error do: [:ex | (RsError canNotGetReply) signal].
	replyToken = 43 "$+ asInteger"
		ifTrue: [^ self parseSingleLine].
	replyToken = 58 "$: asInteger"
		ifTrue: [^ self parseInteger].
	replyToken = 36 "$$ asInteger"
		ifTrue: [^ self parseBulkReply].
	replyToken = 42 "$* asInteger"
		ifTrue: [^ self parseMultiBulkReply].
	replyToken = 45 "$- asInteger"
		ifTrue: [^ self parseError].
		
	(RsError invalidReplyToken) signal
]

{ #category : 'private replies' }
RsRedisEndpoint >> parseSingleLine [
	^self stringFromUtf8Bytes: self readSingleLineAsBytes
]

{ #category : 'commands-expiration' }
RsRedisEndpoint >> persist: aKey [
	"PERSIST key
Available since 2.2.0.
Time complexity: O(1)
Remove the existing timeout on key, turning the key from volatile (a key with an expire set) to persistent (a key that will never expire as no timeout is associated)."

	^ self
		unifiedCommand:
			{'PERSIST'.
			aKey}
]

{ #category : 'commands-connection' }
RsRedisEndpoint >> ping [
	^self unifiedCommand: {'PING'}.
	
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> psubscribe: channelPatterns [
	pubsub
		ifTrue: [ self unifiedCommand: {'PSUBSCRIBE'} , channelPatterns ]
		ifFalse: [ (RsError pubsub) signal: 'Not in pubsub mode, pass a callback block first.' ].
	channels := channelPatterns.
	subscriptionMode := #patterns.
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> psubscribe: channelPatterns callback: aBlock [ 
	pubsub
		ifTrue: [(RsError pubsub) signal: 'Already in pubsub mode. Unsubscribe first.']
		ifFalse: [self enterPubsub.
			self psubscribe: channelPatterns].
	self spawnReceiveProcess: aBlock
]

{ #category : 'commands-expiration' }
RsRedisEndpoint >> pttl: aKey [
	"Returns the remaining time to live of a key that has an expire set in milliseconds."

	^ self
		unifiedCommand:
			{'PTTL'.
			aKey}
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> publish: channel message: message [
	^ self
		unifiedCommand:
			{'PUBLISH'.
			channel.
			message}
]

{ #category : 'private' }
RsRedisEndpoint >> pubsub [
	^pubsub
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> pubsubChannels: pattern [
	^self unifiedCommand: {'PUBSUB'. 'CHANNELS'} , pattern
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> pubsubNumpat [
	^self unifiedCommand: {'PUBSUB'. 'NUMPAT'}
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> pubsubNumsub: channelsCollection [
	^self unifiedCommand: {'PUBSUB'. 'NUMSUB'} , channelsCollection
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> punsubscribe: channelPatterns [
	self unifiedCommand: {'PUNSUBSCRIBE'} , channelPatterns.
	channels ifNil: [ ^self ].
	channels := channels copyWithoutAll: channelPatterns.
	channels ifEmpty: [subscriptionMode := nil]
]

{ #category : 'commands-connection' }
RsRedisEndpoint >> quit [
	self writeString: 'QUIT'.
	self release
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> rPop: aKey [
	^ self
		unifiedCommand:
			{'RPOP'.
			aKey}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> rPoplPush: sourceKey to: destinationKey [
	^ self
		unifiedCommand:
			{'RPOPLPUSH'.
			sourceKey.
			destinationKey}
]

{ #category : 'commands-lists' }
RsRedisEndpoint >> rPush: aKey value: aValue [ 
	^ self
		unifiedCommand: { 'RPUSH'
		. aKey
		. aValue}
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> randomKey [
	^ self inlineCommand: 'RANDOMKEY'
]

{ #category : 'private replies' }
RsRedisEndpoint >> readSingleLineAsBytes [
	| upToCr |
	upToCr := self socketStream upTo: 13 "Character cr asInteger".
	^ self socketStream peek = 10 "Character lf asInteger"
		ifTrue: [ self socketStream next. upToCr ]
		ifFalse: [ upToCr , self parseSingleLine ]
]

{ #category : 'initialize-release' }
RsRedisEndpoint >> releasePubsub [
	[ self unsubscribe: self channels]
		on: Error
		do: [ :ex |  ].
	listener ifNotNil: [ listener terminate ].
	self exitPubsub.
	listener := nil.
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> rename: oldKey to: newKey [
	^ self
		unifiedCommand:
			{'RENAME'.
			oldKey.
			newKey}
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> renameNx: oldKey to: newKey [
	^ self
		unifiedCommand:
			{'RENAMENX'.
			oldKey.
			newKey}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sAdd: aKey member: aMember [
	^ self
		unifiedCommand:
			{'SADD'.
			aKey.
			aMember}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sCard: aKey [
	^ self
		unifiedCommand:
			{'SCARD'.
			aKey}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sDiff: keys [
	^ self unifiedCommand: {'SDIFF'} , keys
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sDiffStore: destinationKey keys: keys [
	^ self
		unifiedCommand:
			{'SDIFFSTORE'.
			destinationKey} , keys
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sInter: keys [
	^ self unifiedCommand: {'SINTER'} , keys
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sInterStore: destinationKey keys: keys [
	^ self
		unifiedCommand:
			{'SINTERSTORE'.
			destinationKey} , keys
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sIsMember: aKey member: aMember [
	^ (self
		unifiedCommand:
			{'SISMEMBER'.
			aKey.
			aMember}) = 1
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sMembers: aKey [
	^ self
		unifiedCommand:
			{'SMEMBERS'.
			aKey}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sMove: sourceKey to: destinationKey member: aMember [
	^ self
		unifiedCommand:
			{'SMOVE'.
			sourceKey.
			destinationKey.
			aMember}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sPop: aKey [
	^ self
		unifiedCommand:
			{'SPOP'.
			aKey}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sRandMember: aKey [
	^ self
		unifiedCommand:
			{'SRANDMEMBER'.
			aKey}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sRem: aKey member: aMember [
	^ self
		unifiedCommand:
			{'SREM'.
			aKey.
			aMember}
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sUnion: keys [
	^ self unifiedCommand: {'SUNION'} , keys
]

{ #category : 'commands-sets' }
RsRedisEndpoint >> sUnionStore: destinationKey keys: keys [
	^ self
		unifiedCommand:
			{'SUNIONSTORE'.
			destinationKey} , keys
]

{ #category : 'commands-server' }
RsRedisEndpoint >> save [
	^ self inlineCommand: 'SAVE'
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> select: zeroBasedDbIndex [
	^ self
		unifiedCommand:
			{'SELECT'.
			zeroBasedDbIndex}
]

{ #category : 'accessing' }
RsRedisEndpoint >> sendMutex [
  ^ sendMutex ifNil: [ sendMutex := self portableUtil createMutex ]
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> set: aKey value: aValue [
	^ self
		unifiedCommand:
			{'SET'.
			aKey.
			aValue}
]

{ #category : 'commands-strings' }
RsRedisEndpoint >> setNx: aKey value: aValue [
	^ self
		unifiedCommand:
			{'SETNX'.
			aKey.
			aValue}
]

{ #category : 'commands-server' }
RsRedisEndpoint >> shutdown [
	self socketStream
		nextPutAll: 'SHUTDOWN';
		crlf;
		flush.
	self release
]

{ #category : 'commands-server' }
RsRedisEndpoint >> slaveOf: host port: hostPort [
	^ self
		unifiedCommand:
			{'SLAVEOF'.
			host.
			hostPort}
]

{ #category : 'commands-sorting' }
RsRedisEndpoint >> sort: aKey [
	^ self
		unifiedCommand:
			{'SORT'.
			aKey}
]

{ #category : 'commands-sorting' }
RsRedisEndpoint >> sort: aKey by: aPattern [
	^ self
		unifiedCommand:
			{'SORT'.
			aKey.
			'BY'.
			aPattern}
]

{ #category : 'commands-sorting' }
RsRedisEndpoint >> sortByQuery: aRedisSortQuery [ 
	^ aRedisSortQuery execute
]

{ #category : 'factory' }
RsRedisEndpoint >> sortQueryAt: key [
	^RsSortQuery key: key on: self
	
]

{ #category : 'private' }
RsRedisEndpoint >> spawnReceiveProcess: aBlock [
	"The format of messages are different for subscribe vs. psubscribe.
	Redis returns 3 elements for subcribe, 4 for psubscribe, with the
	acutal matched channel. I'm putting the matched channel last, rather
	than third, so for the client, we will always get type, channel,
	message, then finally the actual matched channel or nil."

	listener := [
	            [ self pubsub ] whileTrue: [
		            | message |
		            self socketIsConnected ifFalse: [ self waitFor: 3 ].
		            message := [ self parseReply ]
			                       on: RsError
			                       do: [ :ex |
				                       self socketIsConnected ifFalse: [
					                       self exitPubsub.
					                       self onErrorSignaled: ex ].
				                       nil ]. "Ignore timeout, etc"
		            message ifNotNil: [
			            self handlePubsubMessage: message callback: aBlock ] ] ]
		            forkAt: self subscriptionListenPriority
]

{ #category : 'private-encoding' }
RsRedisEndpoint >> stringFromUtf8Bytes: aByteArray [
	aByteArray ifNil: [ ^nil ].
	^self portableUtil stringFromUtf8Bytes: aByteArray
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> subscribe: channelArray [
	pubsub
		ifTrue: [ self unifiedCommand: {'SUBSCRIBE'} , channelArray ]
		ifFalse: [ (RsError pubsub) signal: 'Not in pubsub mode, pass a callback block first.' ].
	channels := channelArray.
	subscriptionMode := #normal.
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> subscribe: channelArray callback: aBlock [ 
	pubsub
		ifTrue: [(RsError pubsub) signal: 'Already in pubsub mode. Unsubscribe first.']
		ifFalse: [self enterPubsub.
			self subscribe: channelArray].
	self spawnReceiveProcess: aBlock
]

{ #category : 'accessing' }
RsRedisEndpoint >> subscriptionListenPriority [
	^ self settings receivingProcessPriority
]

{ #category : 'accessing' }
RsRedisEndpoint >> subscriptionMode [
	^subscriptionMode
]

{ #category : 'commands-expiration' }
RsRedisEndpoint >> ttl: aKey [
	^ self
		unifiedCommand:
			{'TTL'.
			aKey}
]

{ #category : 'commands-generic' }
RsRedisEndpoint >> type: aKey [ 
	^ self unifiedCommand: {'TYPE' . aKey}
]

{ #category : 'private commands' }
RsRedisEndpoint >> unifiedCommand: args [
	| received |
	received := nil.
	self sendMutex
		critical: [ self
				errorHandlingDo: [ self writeUnifiedCommand: args.
					pubsub ifFalse: [ received := self parseReply ] ].
			received ifNotNil: [ self onDataReceived: received ] ].
	^ received
]

{ #category : 'private' }
RsRedisEndpoint >> unixEpoch [
	"Answer the difference in seconds between the unix epoch and the
	squeak epoch"
	^ 2177452800
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> unsubscribe [
	self inlineCommand: 'UNSUBSCRIBE'.
	channels := nil.
	subscriptionMode := nil
]

{ #category : 'commands-pubsub' }
RsRedisEndpoint >> unsubscribe: channelArray [
	self unifiedCommand: {'UNSUBSCRIBE'} , channelArray.
	channels ifNil: [ ^self ].
	channels := channels copyWithoutAll: channelArray.
	channels ifEmpty: [subscriptionMode := nil]
]

{ #category : 'commands-transactions' }
RsRedisEndpoint >> unwatch [
	^ self inlineCommand: 'UNWATCH'
]

{ #category : 'private-encoding' }
RsRedisEndpoint >> utf8BytesFromString: aString [
	aString ifNil: [ ^nil ].
	^self portableUtil utf8BytesFromString: aString
]

{ #category : 'commands-transactions' }
RsRedisEndpoint >> watch: keys [
	self unifiedCommand: {'WATCH'} , keys
]

{ #category : 'private commands' }
RsRedisEndpoint >> writeBytes: bytes to: aSocketStream [
	aSocketStream nextPutAll: bytes.
	aSocketStream nextPutAll: #[13 10].
]

{ #category : 'private commands' }
RsRedisEndpoint >> writeString: aString [
	| bytes strm |
	bytes := self utf8BytesFromString: aString.
	strm := self socketStream ifNil: [^self].
	strm nextPutAll: bytes.
	strm nextPutAll: #[13 10]. "crlf"
	strm flush
]

{ #category : 'private commands' }
RsRedisEndpoint >> writeUnifiedCommand: args [
	| strm |
	strm := self socketStream ifNil: [^self].
	strm nextPut: $* asInteger.
	self writeBytes: args size asString asByteArray to: strm.
	args
		do: [ :ea | 
			| bytes |
			bytes := (self utf8BytesFromString: ea asString).
			strm nextPut: $$ asInteger.
			self writeBytes: bytes size asString asByteArray to: strm.
			self writeBytes: bytes to: strm].
	strm flush
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zAdd: aKey score: aScore member: aMember [
	^ self
		unifiedCommand:
			{'ZADD'.
			aKey.
			aScore.
			aMember}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zCard: aKey [
	^ self
		unifiedCommand:
			{'ZCARD'.
			aKey}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zIncrBy: aKey increment: anIncrement member: aMember [
	^ self
		unifiedCommand:
			{'ZINCRBY'.
			aKey.
			anIncrement.
			aMember}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zLexCount: key min: min max: max [ 
	^ self 
		unifiedCommand: {'ZLEXCOUNT'. key. min. max }
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRange: aKey start: aStart end: anEnd [ 
	^ self
		zRange: aKey
		start: aStart
		end: anEnd
		includeScore: false
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRange: aKey start: aStart end: anEnd includeScore: shouldIncludeScore [
	| args |
	args := shouldIncludeScore
		ifTrue: [ 
			{aKey.
			aStart.
			anEnd.
			'WITHSCORES'} ]
		ifFalse: [ 
			{aKey.
			aStart.
			anEnd} ].
	^ self unifiedCommand: {'ZRANGE'} , args
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRangeByLex: key min: min max: max [ 
	^ self 
		unifiedCommand:{'ZRANGEBYLEX'. key. min. max }
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRangeByLex: key min: min max: max offset: offset count: count [
	^ self 
		unifiedCommand: {'ZRANGEBYLEX'. key. min. max. 'LIMIT'. offset. count }
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRangeByScore: aKey min: aMin max: aMax [
	^ self
		unifiedCommand:
			{'ZRANGEBYSCORE'.
			aKey.
			aMin.
			aMax}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRangeByScore: aKey min: aMin max: aMax offset: anOffset count: aCount [
	^ self
		unifiedCommand:
			{'ZRANGEBYSCORE'.
			aKey.
			aMin.
			aMax.
			'LIMIT'.
			anOffset.
			aCount}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRem: aKey member: aMember [
	^ self
		unifiedCommand:
			{'ZREM'.
			aKey.
			aMember}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRemRangeByLex: key min: min max: max [ 
	^ self 
		unifiedCommand:{ 'ZREMRANGEBYLEX'. key. min. max }
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRemRangeByRank: key start: start end: end [
	^ self
		unifiedCommand:
			{'ZREMRANGEBYRANK'.
			key.
			start.
			end}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRemRangeByScore: key min: min max: max [
	^ self
		unifiedCommand:
			{'ZREMRANGEBYSCORE'.
			key.
			min.
			max}
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRevRange: aKey start: aStart end: anEnd [ 
	^ self
		zRevRange: aKey
		start: aStart
		end: anEnd
		includeScore: false
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRevRange: aKey start: aStart end: anEnd includeScore: shouldIncludeScore [
	| args |
	args := shouldIncludeScore
		ifTrue: [ 
			{aKey.
			aStart.
			anEnd.
			'WITHSCORES'} ]
		ifFalse: [ 
			{aKey.
			aStart.
			anEnd} ].
	^ self unifiedCommand: {'ZREVRANGE'} , args
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRevRangeByLex: key min: min max: max [ 
	^ self 
		unifiedCommand:{ 'ZREVRANGEBYLEX'. key. min. max }
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zRevRangeByLex: key min: min max: max offset: offset count: count [
	^ self 
		unifiedCommand: { 'ZREVRANGEBYLEX'. key. min. max. 'LIMIT'. offset. count }
]

{ #category : 'commands-sorted-sets' }
RsRedisEndpoint >> zScore: aKey element: anElement [
	^ self
		unifiedCommand:
			{'ZSCORE'.
			aKey.
			anElement}
]
