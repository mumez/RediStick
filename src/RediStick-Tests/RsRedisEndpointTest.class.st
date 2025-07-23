Class {
	#name : 'RsRedisEndpointTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

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
