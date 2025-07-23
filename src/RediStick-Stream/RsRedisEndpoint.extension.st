Extension { #name : 'RsRedisEndpoint' }

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> createStreamEntryFrom: rawEntryCollection [ 
	rawEntryCollection ifNil: [ ^#() ].
	^ rawEntryCollection collect: [ :each | RsStreamEntry fromOrderedCollection: each ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAck: key group: group id: id [
	^ self xAck: key group: group ids: {id}
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAck: key group: group ids: ids [
	| args |
	args := {
		        'XACK'.
		        key.
		        group } asOrderedCollection.
	args addAll: ids.
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAdd: key createNotExists: createNotExists trimOptions: trimOptions id: id fieldsAndValues: fieldAndValues [
	| args fieldAndVals |
	args := {
		        'XADD'.
		        key } asOrderedCollection.
	createNotExists ifFalse: [ args add: 'NOMKSTREAM' ].
	trimOptions ifNotNil: [ args addAll: trimOptions asArray ].
	id ifNil: [ args add: '*' ] ifNotNil: [ args add: id asString ].
	fieldAndVals := fieldAndValues isDictionary
		                ifTrue: [ fieldAndValues associations ]
		                ifFalse: [ fieldAndValues ].
	args addAll: (fieldAndVals gather: [ :each |{each key. each value}]).
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAdd: key createNotExists: createNotExists trimUsing: trimOptionsBlock id: id fieldsAndValues: fieldAndValues [
	| trimOptions |
	trimOptions := RsStreamTrimOptions new.
	trimOptionsBlock value: trimOptions.
	^ self xAdd: key createNotExists: createNotExists trimOptions: trimOptions id: id fieldsAndValues: fieldAndValues
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAdd: key field: field value: value [
	^ self xAdd: key id: nil field: field value: value
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAdd: key fieldAndValues: fieldAndValues [
	^ self xAdd: key id: nil fieldAndValues: fieldAndValues
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAdd: key id: id field: field value: value [
	^ self xAdd: key id: id fieldAndValues: {field -> value}
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAdd: key id: id fieldAndValues: fieldAndValues [
	^ self xAdd: key createNotExists: true trimOptions: nil id: id fieldsAndValues: fieldAndValues
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start [
	^ self xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start count: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start count: count [
	^ self xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start count: count idsOnly: false
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start count: count idsOnly: idsOnly [
	| args |
	args := {
		        'XAUTOCLAIM'.
		        key.
		        group.
		        consumer.
		        minIdleTime.
		        start } asOrderedCollection.
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	idsOnly ifTrue: [ args add: 'JUSTID' ].
	^ RsAutoClaimResult fromOrderedCollection: (self unifiedCommand: args)
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start idsOnly: idsOnly [
	^ self xAutoClaim: key group: group consumer: consumer minIdleTime: minIdleTime start: start count: nil idsOnly: idsOnly
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xClaim: key group: group consumer: consumer minIdleTime: minIdleTime id: id [
	^ self xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: {id}
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids [
	^ self xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids using: [:opts| ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids options: claimOptions [
	| args |
	args := {
		        'XCLAIM'.
		        key.
		        group.
		        consumer.
		        minIdleTime } asOrderedCollection.
	args addAll: ids.
	claimOptions ifNotNil: [ args addAll: claimOptions asArray ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids using: optionsBlock [
	| claimOptions |
	claimOptions := RsStreamClaimOptions new.
	optionsBlock value: claimOptions.
	^ self xClaim: key group: group consumer: consumer minIdleTime: minIdleTime ids: ids options: claimOptions
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xDel: key id: id [

	^ self unifiedCommand: {
			  'XDEL'.
			  key.
			  id asString }
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xDel: key ids: ids [
	| args |
	args := {
		        'XDEL'.
		        key } asOrderedCollection.
	args addAll: (ids collect: [ :each | each asString ]).
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupCreate: key group: group id: id [
	^ self xGroupCreate: key group: group id: id createNotExists: false entriesRead: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupCreate: key group: group id: id createNotExists: createNotExists [
	^ self xGroupCreate: key group: group id: id createNotExists: createNotExists entriesRead: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupCreate: key group: group id: id createNotExists: createNotExists entriesRead: entriesRead [
	| args |
	args := {
		        'XGROUP'.
		        'CREATE'.
		        key.
		        group.
		        id asString } asOrderedCollection.
	createNotExists ifTrue: [ args add: 'MKSTREAM' ].
	entriesRead ifNotNil: [
		args addAll: {
				'ENTRIESREAD'.
				entriesRead } ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupCreate: key group: group id: id entriesRead: entriesRead [
	^ self xGroupCreate: key group: group id: id createNotExists: false entriesRead: entriesRead
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupCreateConsumer: key group: group consumer: consumer [
	| args |
	args := {
		        'XGROUP'.
		        'CREATECONSUMER'.
		        key.
		        group.
		        consumer } asOrderedCollection.
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupDelConsumer: key group: group consumer: consumer [
	| args |
	args := {
		        'XGROUP'.
		        'DELCONSUMER'.
		        key.
		        group.
		        consumer } asOrderedCollection.
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupDestroy: key group: group [
	| args |
	args := {
		        'XGROUP'.
		        'DESTROY'.
		        key.
		        group } asOrderedCollection.
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupRead: key id: id group: group consumer: consumer [
	^ self xGroupRead: key id: id group: group consumer: consumer using: [ :opts | ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupRead: key id: id group: group consumer: consumer blocking: milliseconds [
	^ self xGroupRead: key id: id group: group consumer: consumer using: [ :opts | opts blocking: milliseconds ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupRead: key id: id group: group consumer: consumer blocking: milliseconds count: count [
	^ self
		  xGroupRead: key
		  id: id
		  group: group
		  consumer: consumer
		  using: [ :opts |
			  opts
				  blocking: milliseconds;
				  count: count ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupRead: key id: id group: group consumer: consumer count: count [
	^ self xGroupRead: key id: id group: group consumer: consumer using: [ :opts | opts count: count ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupRead: key id: id group: group consumer: consumer using: optionsBlock [
	| keysAndValues messageDict |
	keysAndValues := { key -> id }.
	messageDict := self xGroupReadKeysAndIds: keysAndValues group: group consumer: consumer using: optionsBlock.
	^ messageDict at: key ifAbsent: [ #() ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer [
	^ self xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: [:opts | ].
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer blocking: milliseconds [
	^ self xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: [:opts | opts blocking: milliseconds ].
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer count: count [
	^ self xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: [:opts | opts count: count ].
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: optionsBlock [
	| opts keys ids |
	opts := RsStreamGroupReadOptions new.
	optionsBlock value: opts.
	keys := keysAndIds collect: [ :each | each key ].
	ids := keysAndIds collect: [ :each | each value ].
	^ self xGroupReadOptions: opts group: group consumer: consumer keys: keys ids: ids
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupReadOptions: options group: group consumer: consumer keys: keys ids: ids [
	| args vals dict |
	args := {
		        'XREADGROUP'.
		        'GROUP'.
		        group.
		        consumer } asOrderedCollection.
	args addAll: options asArray.
	args add: 'STREAMS'.
	args addAll: keys.
	args addAll: ids.
	vals := self unifiedCommand: args.
	dict := Dictionary new.
	vals ifNil: [ ^ dict ].
	vals do: [ :eachPair |
		dict
			at: eachPair first
			put: (self createStreamEntryFrom: eachPair last) ].
	keys do: [ :each | dict at: each ifAbsentPut: [ #(  ) ] ].
	^ dict
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xGroupSetId: key group: group id: id entriesRead: entriesRead [
	| args |
	args := {
		        'XGROUP'.
		        'SETID'.
		        key.
		        group.
		        id } asOrderedCollection.
	entriesRead ifNotNil: [
		args addAll: {
				'ENTRIESREAD'.
				entriesRead } ].
	^ self unifiedCommand: args
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xInfoConsumers: key group: group [
	| entries |
	entries := self unifiedCommand: { 'XINFO'. 'CONSUMERS'. key. group }.
	entries ifNil: [ ^#() ].
	^ entries collect: [ :each | RsStreamConsumerInfo fromOrderedCollection: each ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xInfoGroups: key [
	| entries |
	entries := self unifiedCommand: { 'XINFO'. 'GROUPS'. key }.
	entries ifNil: [ ^#() ].
	^ entries collect: [ :each | RsStreamGroupInfo fromOrderedCollection: each ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xInfoStream: key [
	^ self xInfoStream: key full: false count: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xInfoStream: key full: full [
	^ self xInfoStream: key full: full count: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xInfoStream: key full: full count: count [
	| args entries |
	args := {
		        'XINFO'.
		        'STREAM'.
		        key } asOrderedCollection.
	full ifTrue: [
		args add: 'FULL'.
		count ifNotNil: [
			args addAll: {
					'COUNT'.
					count } ] ].

	entries :=  self unifiedCommand: args.
	^ RsStreamInfo fromOrderedCollection: entries 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xLen: key [

	^ self unifiedCommand: { 'XLEN'. key }
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xPending: key group: group [
	| ord |
	ord := self unifiedCommand: {
			       'XPENDING'.
			       key.
			       group }.
	^ RsPendingMessagesSummary fromOrderedCollection: ord
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xPending: key group: group start: startId end: endId count: count [
	^ self xPending: key group: group start: startId end: endId count: count minIdleMilliseconds: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xPending: key group: group start: startId end: endId count: count consumer: consumer [
	^ self xPending: key group: group start: startId end: endId count: count consumer: consumer minIdleMilliseconds: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xPending: key group: group start: startId end: endId count: count consumer: consumer minIdleMilliseconds: milliseconds [
	| opts ord |
	opts := RsStreamPendingMessagesOptions new.
	opts start: startId; end: endId; count: count.
	consumer ifNotNil: [:con | opts consumer: con ].
	milliseconds ifNotNil: [:msecs | opts minIdleMilliseconds: msecs ].
	ord := self unifiedCommand: {
			       'XPENDING'.
			       key.
			       group }, opts asArray.
	^ ord collect: [:each | RsPendingMessage fromOrderedCollection: each]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xPending: key group: group start: startId end: endId count: count minIdleMilliseconds: milliseconds [
	^ self xPending: key group: group start: startId end: endId count: count consumer: nil minIdleMilliseconds: milliseconds
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key count: count [
	^ self xRange: key start: '-' end: '+' count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key from: startId [
	^ self xRange: key start: startId end: '+' 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key from: startId count: count [
	^ self xRange: key start: startId asString end: '+' count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: command key: key start: startId end: endId count: count [
	| args vals |
	args := {
		        command.
		        key.
		        startId asString.
		        endId asString} asOrderedCollection.
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	vals := self unifiedCommand: args.
	^ self createStreamEntryFrom: vals
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key nextFrom: startId count: count [
	^ self xRange: key start: ('(', startId asString) end: '+' count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key start: startId end: endId [ 
	^ self xRange: key start: startId end: endId count: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key start: startId end: endId count: count [
	^ self xRange: 'XRANGE' key: key start: startId end: endId count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRange: key to: endId [
	^ self xRange: key start: '-' end: endId 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRangeAll: key [
	^ self xRange: key start: '-' end: '+' 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRead: key id: id [
	^ self xRead: key id: id using: [ :opts | ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRead: key id: id blocking: milliseconds [
	^ self xRead: key id: id using: [ :opts | opts blocking: milliseconds ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRead: key id: id blocking: milliseconds count: count [
	^ self xRead: key id: id using: [ :opts | opts blocking: milliseconds; count: count ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRead: key id: id count: count [
	^ self xRead: key id: id using: [ :opts | opts count: count ] 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRead: key id: id using: optionsBlock [
	| keysAndValues messageDict |
	keysAndValues := { key -> id }.
	messageDict := self xReadKeysAndIds: keysAndValues using: optionsBlock.
	^ messageDict at: key ifAbsent: [ #() ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xReadKeysAndIds: keysAndIds blocking: milliseconds [
	^ self xReadKeysAndIds: keysAndIds using: [:opts | opts blocking: milliseconds]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xReadKeysAndIds: keysAndIds count: count [
	^ self xReadKeysAndIds: keysAndIds using: [:opts | opts count: count]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xReadKeysAndIds: keysAndIds using: optionsBlock [
	| opts keys ids |
	opts := RsStreamReadOptions new.
	optionsBlock value: opts.
	keys := keysAndIds collect: [ :each | each key asString ].
	ids := keysAndIds collect: [ :each | each value asString ].
	^ self xReadOptions: opts keys: keys ids: ids
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xReadOptions: options keys: keys ids: ids [
	| args vals dict |
	args := { 'XREAD' } asOrderedCollection.
	args addAll: options asArray.
	args add: 'STREAMS'.
	args addAll: keys.
	args addAll: ids.
	vals := self unifiedCommand: args.
	dict := Dictionary new.
	vals ifNil: [ ^ dict ].
	vals do: [ :eachPair  | 
		dict at: eachPair first put: (self createStreamEntryFrom: eachPair last) ].
	keys do: [ :each | 
		dict at: each ifAbsentPut: [ #() ]].
	^dict
	
	
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key count: count [
	^ self xRevRange: key start: '+' end: '-' count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key from: startId [
	^ self xRevRange: key start: startId end: '-' 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key from: startId count: count [
	^ self xRevRange: key start: startId asString end: '-' count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key nextFrom: startId count: count [
	^ self xRevRange: key start: ('(', startId asString) end: '-' count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key start: startId end: endId [ 
	^ self xRevRange: key start: startId end: endId count: nil
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key start: startId end: endId count: count [
	^ self xRange: 'XREVRANGE' key: key start: startId end: endId count: count
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRange: key to: endId [
	^ self xRevRange: key start: '-' end: endId 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xRevRangeAll: key [
	^ self xRevRange: key start: '-' end: '+' 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xSet: key lastId: lastId [

	^ self unifiedCommand: {
			  'XSETID'.
			  key.
			  lastId asString }
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xTrim: key maxLen: maxLength [
	^ self xTrim: key using: [ :opts | opts maxLen: maxLength ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xTrim: key maxLenAtLeast: maxLength [
	^ self xTrim: key using: [ :opts | opts maxLenAtLeast: maxLength ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xTrim: key minId: minId [
	^ self xTrim: key using: [ :opts | opts minId: minId ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xTrim: key minIdAtLeast: minId [
	^ self xTrim: key using: [ :opts | opts minIdAtLeast: minId ]
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xTrim: key options: trimOptions [
	| args |
	args := {
		        'XTRIM'.
		        key } asOrderedCollection.
	trimOptions ifNotNil: [ args addAll: trimOptions asArray ].
	^ self unifiedCommand: args 
]

{ #category : '*RediStick-Stream' }
RsRedisEndpoint >> xTrim: key using: optionsBlock [
	| trimOptions |
	trimOptions := RsStreamTrimOptions new.
	optionsBlock value: trimOptions.
	^ self xTrim: key options: trimOptions
]
