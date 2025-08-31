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
	
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	
	self assert: result first equals: (STONJSON fromString: value)
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetSetNestedPath [
	| key value result |
	key := 'test:json:nested'.
	value := '{"user": {"name": "Alice", "profile": {"age": 25}}}'.
	
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'user' / 'name').
	self assert: result first equals: 'Alice'.
	
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'user' / 'profile' / 'age').
	self assert: result first equals: 25
]

{ #category : 'tests' }
RsJsonTest >> testJsonSetUpdateValue [
	| key initialValue newAge result |
	key := 'test:json:update'.
	initialValue := '{"name": "Bob", "age": 20}'.
	
	stick endpoint jsonSet: key path: SjJsonPath root value: initialValue.
	
	newAge := '25'.
	stick endpoint jsonSet: key path: (SjJsonPath root / 'age') value: newAge.
	
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'age').
	self assert: result first equals: newAge asInteger
]

