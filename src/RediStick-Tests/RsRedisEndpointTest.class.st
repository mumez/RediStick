Class {
	#name : 'RsRedisEndpointTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExOptionsNil [
	| key |
	key := 'testGetExOptionsNil'.
	stick endpoint set: key value: 'v' using: [ :opts | opts expireIn: 100 ].
	self assert: (stick endpoint getEx: key options: nil) equals: 'v'.
	self assert: ((stick endpoint ttl: key) between: 90 and: 100)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExUsingExpireAt [
	| key |
	key := 'testGetExUsingExpireAt'.
	stick endpoint set: key value: 'v'.
	self
		assert: (stick endpoint getEx: key using: [ :opts | opts expireAt: DateAndTime now + 100 seconds ])
		equals: 'v'.
	self assert: ((stick endpoint ttl: key) between: 90 and: 100)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExUsingExpireAtMilliseconds [
	| key |
	key := 'testGetExUsingExpireAtMilliseconds'.
	stick endpoint set: key value: 'v'.
	self
		assert: (stick endpoint getEx: key using: [ :opts |
				 opts expireAtMilliseconds: DateAndTime now + 100 seconds ])
		equals: 'v'.
	self assert: ((stick endpoint pttl: key) between: 90000 and: 100000)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExUsingExpireIn [
	| key |
	key := 'testGetExUsingExpireIn'.
	stick endpoint set: key value: 'v'.
	self assert: (stick endpoint ttl: key) equals: -1.
	self assert: (stick endpoint getEx: key using: [ :opts | opts expireIn: 60 ]) equals: 'v'.
	self assert: ((stick endpoint ttl: key) between: 50 and: 60)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExUsingExpireInMilliseconds [
	| key |
	key := 'testGetExUsingExpireInMilliseconds'.
	stick endpoint set: key value: 'v'.
	self
		assert: (stick endpoint getEx: key using: [ :opts | opts expireInMilliseconds: 100000 ])
		equals: 'v'.
	self assert: ((stick endpoint pttl: key) between: 90000 and: 100000)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExUsingMissingKey [
	self assert: (stick endpoint getEx: 'testGetExUsingMissingKey' using: [ :opts | opts expireIn: 60 ]) isNil.
	self assert: (stick endpoint ttl: 'testGetExUsingMissingKey') equals: -2
]

{ #category : 'tests' }
RsRedisEndpointTest >> testGetExUsingPersist [
	| key |
	key := 'testGetExUsingPersist'.
	stick endpoint set: key value: 'v' using: [ :opts | opts expireIn: 100 ].
	self assert: (stick endpoint getEx: key using: [ :opts | opts persist ]) equals: 'v'.
	self assert: (stick endpoint ttl: key) equals: -1
]

{ #category : 'tests' }
RsRedisEndpointTest >> testHSet [
	| value |
	value := self newDateAndTimeValue.
	stick endpoint hSet: 'testHSet' field: 'field1'  value: value.
	self assert: (stick endpoint hGetAll: 'testHSet') equals:  (Dictionary with: ('field1' -> value))
]

{ #category : 'tests' }
RsRedisEndpointTest >> testHSetWithDictionary [
	| dict |
	dict := {'key1' -> 'value1'. 'key2' -> 'value2'} as: Dictionary.
	stick endpoint hSet: 'testHSetWithDictionary' dictionary: dict.
	self assert: (stick endpoint hGetAll: 'testHSetWithDictionary') equals: dict.
	self
		assert: (stick endpoint hGet: 'testHSetWithDictionary' field: 'key1')
		equals: (dict at: 'key1')
]

{ #category : 'tests' }
RsRedisEndpointTest >> testLIndex [
	| listName elem |
	listName := 'testLIndex'.
	0 to: 4 do: [ :idx |
		stick endpoint rPush: listName value: idx.
	].
	
	elem := stick endpoint lIndex: listName value: 2.
	self assert: elem equals: '2'.
	
	elem := stick endpoint lIndex: listName value: 4.
	self assert: elem equals: '4'.
	
	elem := stick endpoint lIndex: listName value: 10.
	self assert: elem equals: nil.
	
	
]

{ #category : 'tests' }
RsRedisEndpointTest >> testLInsert [
	| listName elems1 elems2 |
	listName := 'testLInsert'.
	#('one' 'two' 'three') do: [ :each |
		stick endpoint rPush: listName value: each.
	].
	
	stick endpoint lInsert: listName value: 'val1' after: 'two'.
	elems1 := stick endpoint lRange: listName start: 0 end: -1.
	
	self assertCollection: elems1 asArray equals: #('one' 'two' 'val1' 'three').
	
	stick endpoint lInsert: listName value: 'val2' before: 'two'.
	elems2 := stick endpoint lRange: listName start: 0 end: -1.
	
	self assertCollection: elems2 asArray equals: #('one' 'val2' 'two' 'val1' 'three')
	
]

{ #category : 'tests' }
RsRedisEndpointTest >> testLMove [
	| listName1 listName2 elems1 elems2 |
	listName1 := 'testLMove1'.
	1 to: 3 do: [ :idx |
		stick endpoint rPush: listName1 value: idx.
	].
	listName2 := 'testLMove2'.
	1 to: 3 do: [ :idx |
		stick endpoint rPush: listName2 value: idx*10.
	].
	
	stick endpoint lMoveFrom: listName1 to: listName2.
	
	elems1 := stick endpoint lRange: listName1 start: 0 end: -1.
	elems2 := stick endpoint lRange: listName2 start: 0 end: -1.
	
	self assertCollection: elems1 asArray equals: #('1' '2').
	self assertCollection: elems2 asArray equals: #('3' '10' '20' '30').
	
	stick endpoint lMoveFrom: listName2 removing: 'LEFT' to: listName1 adding: 'RIGHT'.
	
	elems1 := stick endpoint lRange: listName1 start: 0 end: -1.
	elems2 := stick endpoint lRange: listName2 start: 0 end: -1.
	
	self assertCollection: elems1 asArray equals: #('1' '2' '3').
	self assertCollection: elems2 asArray equals: #('10' '20' '30').
]

{ #category : 'tests' }
RsRedisEndpointTest >> testLPos [
	| listName pos positions |
	listName := 'testLPos'.
	0 to: 10 do: [ :idx |
		stick endpoint rPush: listName value: idx.
	].
	0 to: 10 do: [ :idx |
		stick endpoint rPush: listName value: idx.
	].
	
	pos := stick endpoint lPos: listName value: '2'.
	self assert: pos equals: 2.
	
	pos := stick endpoint lPosBackward: listName value: '2' maxlen: 10.
	self assert: pos equals: 13.
	
	pos := stick endpoint lPosBackward: listName value: '2' maxlen: 5.
	self assert: pos isNil.
	
	positions := stick endpoint lPos: listName value: '2' count: 0.
	self assertCollection: positions asArray equals: #(2 13)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testLPushPop [
	| listName elem elems |
	listName := 'testLPushPop'.
	stick endpoint lPush: listName value: 'val1'.
	stick endpoint lPush: listName value: 'val2'.
	stick endpoint lPush: listName value: 'val3'.
	elem := stick endpoint lPop: listName.
	self assert: elem equals: 'val3'.
	
	elems := stick endpoint lPop: listName count: 2.
	self assertCollection: elems asArray equals: #('val2' 'val1').
]

{ #category : 'tests' }
RsRedisEndpointTest >> testMSetWithDictionary [
	| dict |
	dict := Dictionary with: 'keyA' -> 'valueA' with: 'keyB' -> 'valueB'.
	stick endpoint mSet: dict.
	self assert: (stick endpoint get: 'keyA') equals: 'valueA'.
	self assert: (stick endpoint get: 'keyB') equals: 'valueB'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetAndGet [
	| value |
	value := self newDateAndTimeValue.
	stick endpoint set: 'testSetAndGet' value: value.
	self assert: (stick endpoint get: 'testSetAndGet') equals: value
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingExpireAt [
	| ttl |
	stick endpoint set: 'testSetUsingExpireAt' value: 'v' using: [ :opts |
		opts expireAt: DateAndTime now + 100 seconds ].
	ttl := stick endpoint ttl: 'testSetUsingExpireAt'.
	self assert: (ttl between: 90 and: 100)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingExpireAtMilliseconds [
	| pttl |
	stick endpoint set: 'testSetUsingExpireAtMilliseconds' value: 'v' using: [ :opts |
		opts expireAtMilliseconds: DateAndTime now + 100 seconds ].
	pttl := stick endpoint pttl: 'testSetUsingExpireAtMilliseconds'.
	self assert: (pttl between: 90000 and: 100000)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingExpireIn [
	| ttl |
	self
		assert: (stick endpoint set: 'testSetUsingExpireIn' value: 'v' using: [ :opts | opts expireIn: 100 ])
		equals: 'OK'.
	ttl := stick endpoint ttl: 'testSetUsingExpireIn'.
	self assert: (ttl between: 90 and: 100)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingExpireInMilliseconds [
	| pttl |
	stick endpoint set: 'testSetUsingExpireInMilliseconds' value: 'v' using: [ :opts |
		opts expireInMilliseconds: 100000 ].
	pttl := stick endpoint pttl: 'testSetUsingExpireInMilliseconds'.
	self assert: (pttl between: 90000 and: 100000)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingGet [
	| key |
	key := 'testSetUsingGet'.
	self assert: (stick endpoint set: key value: 'first' using: [ :opts | opts get ]) isNil.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts get ]) equals: 'first'.
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIfAlreadyExists [
	| key |
	key := 'testSetUsingIfAlreadyExists'.
	self assert: (stick endpoint set: key value: 'first' using: [ :opts | opts ifAlreadyExists ]) isNil.
	self assert: (stick endpoint get: key) isNil.
	stick endpoint set: key value: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifAlreadyExists ]) equals: 'OK'.
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIfDigestEqual [
	| key digest |
	self skipUnlessRedisVersionAtLeast: #( 8 4 ).
	key := 'testSetUsingIfDigestEqual'.
	stick endpoint set: key value: 'first'.
	digest := stick endpoint unifiedCommand: { 'DIGEST'. key }.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifDigestEqual: '0000000000000000' ]) isNil.
	self assert: (stick endpoint get: key) equals: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifDigestEqual: digest ]) equals: 'OK'.
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIfDigestNotEqual [
	| key digest |
	self skipUnlessRedisVersionAtLeast: #( 8 4 ).
	key := 'testSetUsingIfDigestNotEqual'.
	stick endpoint set: key value: 'first'.
	digest := stick endpoint unifiedCommand: { 'DIGEST'. key }.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifDigestNotEqual: digest ]) isNil.
	self assert: (stick endpoint get: key) equals: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifDigestNotEqual: '0000000000000000' ]) equals: 'OK'.
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIfEqual [
	| key |
	self skipUnlessRedisVersionAtLeast: #( 8 4 ).
	key := 'testSetUsingIfEqual'.
	stick endpoint set: key value: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifEqual: 'other' ]) isNil.
	self assert: (stick endpoint get: key) equals: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifEqual: 'first' ]) equals: 'OK'.
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIfNotEqual [
	| key |
	self skipUnlessRedisVersionAtLeast: #( 8 4 ).
	key := 'testSetUsingIfNotEqual'.
	stick endpoint set: key value: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifNotEqual: 'first' ]) isNil.
	self assert: (stick endpoint get: key) equals: 'first'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifNotEqual: 'other' ]) equals: 'OK'.
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIfNotExists [
	| key |
	key := 'testSetUsingIfNotExists'.
	self assert: (stick endpoint set: key value: 'first' using: [ :opts | opts ifNotExists ]) equals: 'OK'.
	self assert: (stick endpoint set: key value: 'second' using: [ :opts | opts ifNotExists ]) isNil.
	self assert: (stick endpoint get: key) equals: 'first'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingIssueExample [
	| key |
	key := 'testSetUsingIssueExample'.
	self
		assert: (stick endpoint set: key value: 123 using: [ :opts | opts ifNotExists; get; expireIn: 1000 ])
		equals: nil.
	self assert: (stick endpoint get: key) equals: '123'.
	self assert: ((stick endpoint ttl: key) between: 990 and: 1000)
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetUsingKeepTtl [
	| key ttl |
	key := 'testSetUsingKeepTtl'.
	stick endpoint set: key value: 'first' using: [ :opts | opts expireIn: 100 ].
	stick endpoint set: key value: 'second' using: [ :opts | opts keepTtl ].
	ttl := stick endpoint ttl: key.
	self assert: (ttl between: 90 and: 100).
	self assert: (stick endpoint get: key) equals: 'second'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testSetWithNilOptions [
	self assert: (stick endpoint set: 'testSetWithNilOptions' value: 'v' options: nil) equals: 'OK'.
	self assert: (stick endpoint get: 'testSetWithNilOptions') equals: 'v'
]

{ #category : 'tests' }
RsRedisEndpointTest >> testShouldUseRawBytesDefaultsToFalse [
	self deny: stick endpoint shouldUseRawBytes
]

{ #category : 'tests' }
RsRedisEndpointTest >> testShouldUseRawBytesTrueReturnsRawBytes [
	| key bytes result |
	key := 'testShouldUseRawBytesTrueReturnsRawBytes'.
	bytes := #[1 2 3 255 0 128].
	stick endpoint set: key value: bytes.
	stick endpoint shouldUseRawBytes: true.
	result := stick endpoint get: key.
	self assert: result equals: bytes.
	stick endpoint shouldUseRawBytes: false
]

{ #category : 'tests' }
RsRedisEndpointTest >> testShouldUseRawBytesFalseRestoresDecodedResults [
	| key value result |
	key := 'testShouldUseRawBytesFalseRestoresDecodedResults'.
	value := 'someValue'.
	stick endpoint set: key value: value.
	stick endpoint shouldUseRawBytes: true.
	stick endpoint shouldUseRawBytes: false.
	result := stick endpoint get: key.
	self assert: result equals: value
]

{ #category : 'tests' }
RsRedisEndpointTest >> testUseRawBytesWhileRestoresPreviousValueOnCompletion [
	| key bytes result |
	key := 'testUseRawBytesWhileRestoresPreviousValueOnCompletion'.
	bytes := #[9 8 7].
	stick endpoint set: key value: bytes.
	self deny: stick endpoint shouldUseRawBytes.
	result := stick endpoint useRawBytesWhile: [ stick endpoint get: key ].
	self assert: result equals: bytes.
	self deny: stick endpoint shouldUseRawBytes
]

{ #category : 'tests' }
RsRedisEndpointTest >> testUseRawBytesWhileRestoresPreviousValueOnException [
	self deny: stick endpoint shouldUseRawBytes.
	[ stick endpoint useRawBytesWhile: [ Error signal: 'boom' ] ]
		on: Error
		do: [ :ex | ex return: nil ].
	self deny: stick endpoint shouldUseRawBytes
]

{ #category : 'tests' }
RsRedisEndpointTest >> testUseRawBytesWhileSendingStringNotUtf8Encoded [
	| key rawString result |
	key := 'testUseRawBytesWhileSendingStringNotUtf8Encoded'.
	rawString := String new: 3.
	rawString at: 1 put: (Character value: 16r80).
	rawString at: 2 put: (Character value: 16rFF).
	rawString at: 3 put: (Character value: 16r41).
	stick endpoint useRawBytesWhile: [ stick endpoint set: key value: rawString ].
	result := stick endpoint useRawBytesWhile: [ stick endpoint get: key ].
	self assert: result equals: rawString asByteArray
]
