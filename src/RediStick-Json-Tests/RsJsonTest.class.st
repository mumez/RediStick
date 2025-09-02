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

{ #category : 'tests' }
RsJsonTest >> testJsonSetWithIfNotExistsOption [
	| key value1 value2 result |
	key := 'test:json:ifnotexists'.
	value1 := '{"name": "Alice", "status": "active"}'.
	value2 := '{"name": "Bob", "status": "inactive"}'.
	
	"First set should succeed"
	stick endpoint jsonSet: key path: SjJsonPath root value: value1 using: [:opts | opts ifNotExists].
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: (STONJSON fromString: value1).
	
	"Second set with ifNotExists should be ignored since key already exists"
	stick endpoint jsonSet: key path: SjJsonPath root value: value2 using: [:opts | opts ifNotExists].
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: (STONJSON fromString: value1).
	self deny: result first equals: (STONJSON fromString: value2)
]

{ #category : 'tests' }
RsJsonTest >> testJsonSetWithIfAlreadyExistsOption [
	| key value1 value2 result |
	key := 'test:json:ifalreadyexists'.
	value1 := '{"name": "Charlie", "status": "pending"}'.
	value2 := '{"name": "David", "status": "approved"}'.
	
	"First set with ifAlreadyExists should be ignored since key doesn't exist"
	stick endpoint jsonSet: key path: SjJsonPath root value: value1 using: [:opts | opts ifAlreadyExists].
	[result := stick endpoint jsonGet: key path: SjJsonPath root]
		on: Error 
		do: [:ex | result := nil].
	self assert: result isNil.
	
	"Set without options to create the key"
	stick endpoint jsonSet: key path: SjJsonPath root value: value1.
	
	"Second set with ifAlreadyExists should succeed since key exists"
	stick endpoint jsonSet: key path: SjJsonPath root value: value2 using: [:opts | opts ifAlreadyExists].
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: (STONJSON fromString: value2)
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetWithPrettyFormatting [
	| key value result normalResult |
	key := 'test:json:prettyformat'.
	value := '{"user":{"name":"Alice","profile":{"age":25,"active":true}}}'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get with pretty formatting using INDENT, NEWLINE, and SPACE options"
	result := stick endpoint jsonGet: key path: SjJsonPath root using: [:opts | 
		opts indent: String tab.
		opts newLine: String lf.
		opts space: ' '].
	
	"When pretty formatting options are used, result should be raw string"
	self assert: result isString.
	
	"Verify pretty formatting is applied"
	self assert: (result includesSubstring: String tab) description: 'Result should contain tab characters for indentation'.
	self assert: (result includesSubstring: String lf) description: 'Result should contain line feed characters for newlines'.
	self assert: (result includesSubstring: ': ') description: 'Result should contain space after colons'.
	self assert: (result includesSubstring: 'Alice') description: 'Result should contain the data'.
	
	"Get without options for comparison - should return parsed object"
	normalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: normalResult first isDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetMultiplePaths [
	| key value result userNamePath statusPath scorePath |
	key := 'test:json:multiplepaths'.
	value := '{"user": {"name": "Alice", "age": 25}, "status": "active", "score": 100}'.
	userNamePath := SjJsonPath root / 'user' / 'name'.
	statusPath := SjJsonPath root / 'status'.
	scorePath := SjJsonPath root / 'score'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get multiple paths at once"
	result := stick endpoint jsonGet: key paths: {
		userNamePath.
		statusPath.
		scorePath
	}.
	
	"Result should be a dictionary with paths as keys and arrays as values"
	self assert: result isDictionary.
	self assert: result size equals: 3.
	self assert: (result at: userNamePath asString) first equals: 'Alice'.
	self assert: (result at: statusPath asString) first equals: 'active'.
	self assert: (result at: scorePath asString) first equals: 100
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetMultiplePathsWithNonExistentPath [
	| key value result userNamePath nonExistentPath statusPath |
	key := 'test:json:multiplepaths:nonexistent'.
	value := '{"user": {"name": "Bob"}, "status": "inactive"}'.
	userNamePath := SjJsonPath root / 'user' / 'name'.
	nonExistentPath := SjJsonPath root / 'nonexistent'.
	statusPath := SjJsonPath root / 'status'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get multiple paths including a non-existent path"
	result := stick endpoint jsonGet: key paths: {
		userNamePath.
		nonExistentPath.
		statusPath
	}.
	
	"Result should be a dictionary with paths as keys"
	self assert: result isDictionary.
	self assert: result size equals: 3.
	self assert: (result at: userNamePath asString) first equals: 'Bob'.
	"Non-existent path should be included in result with empty array"
	self assert: (result includesKey: nonExistentPath asString).
	self assert: (result at: nonExistentPath asString) isEmpty.
	self assert: (result at: statusPath asString) first equals: 'inactive'
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetMultiplePathsWithPrettyFormatting [
	| key value result dataPath metaPath |
	key := 'test:json:multiplepaths:pretty'.
	value := '{"data": {"items": [1,2,3]}, "meta": {"count": 3}}'.
	dataPath := SjJsonPath root / 'data'.
	metaPath := SjJsonPath root / 'meta'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get multiple paths with pretty formatting"
	result := stick endpoint jsonGet: key paths: {
		dataPath.
		metaPath
	} using: [:opts | 
		opts indent: '  '.
		opts newLine: String lf].
	
	"When pretty formatting is used, result should be raw string"
	self assert: result isString.
	
	"Verify the result contains formatted JSON for both paths"
	self assert: (result includesSubstring: 'items').
	self assert: (result includesSubstring: 'count').
	self assert: (result includesSubstring: String lf).
	
	"Result should be a JSON object with paths as keys"
	self assert: (result includesSubstring: (dataPath asString)).
	self assert: (result includesSubstring: (metaPath asString))
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjKeysBasic [
	| key value result |
	key := 'test:json:objkeys:basic'.
	value := '{"name": "Alice", "age": 30, "city": "Tokyo", "active": true}'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get object keys at root"
	result := stick endpoint jsonObjKeys: key path: SjJsonPath root.
	
	"Result should be a nested collection with object keys in first element"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first isSequenceable.
	self assert: result first size equals: 4.
	self assert: (result first includes: 'name').
	self assert: (result first includes: 'age').
	self assert: (result first includes: 'city').
	self assert: (result first includes: 'active')
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjKeysNestedObject [
	| key value result |
	key := 'test:json:objkeys:nested'.
	value := '{"user": {"profile": {"name": "Bob", "email": "bob@example.com"}, "preferences": {"theme": "dark"}}, "meta": {"version": 1}}'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get object keys at nested path"
	result := stick endpoint jsonObjKeys: key path: (SjJsonPath root / 'user' / 'profile').
	
	"Result should contain keys from the nested object"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first isSequenceable.
	self assert: result first size equals: 2.
	self assert: (result first includes: 'name').
	self assert: (result first includes: 'email')
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjKeysNonObjectPath [
	| key value result |
	key := 'test:json:objkeys:nonobject'.
	value := '{"data": [1, 2, 3], "count": 3}'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get object keys from an array path (should return null)"
	result := stick endpoint jsonObjKeys: key path: (SjJsonPath root / 'data').
	
	"Result should contain nil for non-object paths"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjKeysNonExistentKey [
	| key result |
	key := 'test:json:objkeys:nonexistent'.
	result := stick endpoint jsonObjKeys: key.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjKeysNonExistentPath [
	| key value result |
	key := 'test:json:objkeys:nonexistentpath'.
	value := '{"user": {"name": "Charlie"}}'.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get object keys from non-existent path"
	result := stick endpoint jsonObjKeys: key path: (SjJsonPath root / 'nonexistent').
	
	"Result should be empty collection for non-existent paths"
	self assert: result isSequenceable.
	self assert: result isEmpty
]

