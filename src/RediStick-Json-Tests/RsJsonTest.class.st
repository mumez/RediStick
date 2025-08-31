Class {
	#name : 'RsJsonTest',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-Json-Tests',
	#package : 'RediStick-Json-Tests'
}

{ #category : 'tests' }
RsJsonTest >> testJsonGetSetBasic [
	| key value result |
	key := 'test:json:basic'.
	value := '{"name": "John", "age": 30, "city": "Tokyo"}'.
	
	stick endpoint jsonSet: key path: '$' value: value.
	result := stick endpoint jsonGet: key path: '$'.
	
	self assert: ((STONJSON fromString: result) at: 1) equals: (STONJSON fromString: value)
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetSetNestedPath [
	| key value result |
	key := 'test:json:nested'.
	value := '{"user": {"name": "Alice", "profile": {"age": 25}}}'.
	
	stick endpoint jsonSet: key path: '$' value: value.
	
	result := stick endpoint jsonGet: key path: '$.user.name'.
	self assert: ((STONJSON fromString: result) at: 1) equals: 'Alice'.
	
	result := stick endpoint jsonGet: key path: '$.user.profile.age'.
	self assert: ((STONJSON fromString: result) at: 1) equals: 25
]

{ #category : 'tests' }
RsJsonTest >> testJsonSetUpdateValue [
	| key initialValue newAge result |
	key := 'test:json:update'.
	initialValue := '{"name": "Bob", "age": 20}'.
	
	stick endpoint jsonSet: key path: '$' value: initialValue.
	
	newAge := '25'.
	stick endpoint jsonSet: key path: '$.age' value: newAge.
	
	result := stick endpoint jsonGet: key path: '$.age'.
	self assert: ((STONJSON fromString: result) at: 1) equals: newAge asInteger
]

