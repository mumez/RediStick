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
	value := {'name'->'John'. 'age'->30. 'city'->'Tokyo'} asDictionary.
	
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	
	self assert: result first equals: value
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetSetNestedPath [
	| key value result |
	key := 'test:json:nested'.
	value := {'user'->({'name'->'Alice'. 'profile'->({'age'->25} asDictionary)} asDictionary)} asDictionary.
	
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
	initialValue := {'name'->'Bob'. 'age'->20} asDictionary.
	
	stick endpoint jsonSet: key path: SjJsonPath root value: initialValue.
	
	newAge := 25.
	stick endpoint jsonSet: key path: (SjJsonPath root / 'age') value: newAge.
	
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'age').
	self assert: result first equals: newAge
]

{ #category : 'tests' }
RsJsonTest >> testJsonSetWithIfNotExistsOption [
	| key value1 value2 result |
	key := 'test:json:ifnotexists'.
	value1 := {'name'->'Alice'. 'status'->'active'} asDictionary.
	value2 := {'name'->'Bob'. 'status'->'inactive'} asDictionary.
	
	"First set should succeed"
	stick endpoint jsonSet: key path: SjJsonPath root value: value1 using: [:opts | opts ifNotExists].
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: value1.
	
	"Second set with ifNotExists should be ignored since key already exists"
	stick endpoint jsonSet: key path: SjJsonPath root value: value2 using: [:opts | opts ifNotExists].
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: value1.
	self deny: result first equals: value2
]

{ #category : 'tests' }
RsJsonTest >> testJsonSetWithIfAlreadyExistsOption [
	| key value1 value2 result |
	key := 'test:json:ifalreadyexists'.
	value1 := {'name'->'Charlie'. 'status'->'pending'} asDictionary.
	value2 := {'name'->'David'. 'status'->'approved'} asDictionary.
	
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
	self assert: result first equals: value2
]

{ #category : 'tests' }
RsJsonTest >> testJsonGetWithPrettyFormatting [
	| key value result normalResult |
	key := 'test:json:prettyformat'.
	value := {'user'->({'name'->'Alice'. 'profile'->({'age'->25. 'active'->true} asDictionary)} asDictionary)} asDictionary.
	
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
	value := {'user'->({'name'->'Alice'. 'age'->25} asDictionary). 'status'->'active'. 'score'->100} asDictionary.
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
	value := {'user'->({'name'->'Bob'} asDictionary). 'status'->'inactive'} asDictionary.
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
	value := {'data'->({'items'->{1. 2. 3}} asDictionary). 'meta'->({'count'->3} asDictionary)} asDictionary.
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
	value := {'name'->'Alice'. 'age'->30. 'city'->'Tokyo'. 'active'->true} asDictionary.
	
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
	value := {'user'->({'profile'->({'name'->'Bob'. 'email'->'bob@example.com'} asDictionary). 'preferences'->({'theme'->'dark'} asDictionary)} asDictionary). 'meta'->({'version'->1} asDictionary)} asDictionary.
	
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
	value := {'data'->{1. 2. 3}. 'count'->3} asDictionary.
	
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
	value := {'user'->({'name'->'Charlie'} asDictionary)} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get object keys from non-existent path"
	result := stick endpoint jsonObjKeys: key path: (SjJsonPath root / 'nonexistent').
	
	"Result should be empty collection for non-existent paths"
	self assert: result isSequenceable.
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonSetWithNonStringValues [
	| key numberResult booleanTrueResult booleanFalseResult nilResult |
	key := 'test:json:nonstring'.
	
	"Create root object first"
	stick endpoint jsonSet: key path: SjJsonPath root value: Dictionary new. 
	
	"Test setting a number value"
	stick endpoint jsonSet: key path: (SjJsonPath root / 'number') value: 42.
	numberResult := stick endpoint jsonGet: key path: (SjJsonPath root / 'number').
	self assert: numberResult first equals: 42.
	
	"Test setting a boolean true value"
	stick endpoint jsonSet: key path: (SjJsonPath root / 'boolTrue') value: true.
	booleanTrueResult := stick endpoint jsonGet: key path: (SjJsonPath root / 'boolTrue').
	self assert: booleanTrueResult first equals: true.
	
	"Test setting a boolean false value"
	stick endpoint jsonSet: key path: (SjJsonPath root / 'boolFalse') value: false.
	booleanFalseResult := stick endpoint jsonGet: key path: (SjJsonPath root / 'boolFalse').
	self assert: booleanFalseResult first equals: false.
	
	"Test setting a nil value"
	stick endpoint jsonSet: key path: (SjJsonPath root / 'nullValue') value: nil.
	nilResult := stick endpoint jsonGet: key path: (SjJsonPath root / 'nullValue').
	self assert: nilResult first isNil.
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjLenBasic [
	| key value result |
	key := 'test:json:objlen:basic'.
	value := {'name'->'Alice'. 'age'->30. 'city'->'Tokyo'. 'active'->true} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get object length at root"
	result := stick endpoint jsonObjLen: key.
	
	"Result should be the object length"
	self assert: result equals: 4
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjLenNestedObject [
	| key value result |
	key := 'test:json:objlen:nested'.
	value := {'user'->({'profile'->({'name'->'Bob'. 'email'->'bob@example.com'} asDictionary). 'preferences'->({'theme'->'dark'} asDictionary)} asDictionary). 'meta'->({'version'->1} asDictionary)} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get object length at nested path"
	result := stick endpoint jsonObjLen: key path: (SjJsonPath root / 'user' / 'profile').
	
	"Result should be an array with the object length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 2
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjLenNonObjectPath [
	| key value result |
	key := 'test:json:objlen:nonobject'.
	value := {'data'->{1. 2. 3}. 'count'->3} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get object length from an array path (should return null)"
	result := stick endpoint jsonObjLen: key path: (SjJsonPath root / 'data').
	
	"Result should be an array with nil for non-object paths"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjLenNonExistentKey [
	| key result |
	key := 'test:json:objlen:nonexistent'.
	result := stick endpoint jsonObjLen: key.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjLenNonExistentPath [
	| key value result |
	key := 'test:json:objlen:nonexistentpath'.
	value := {'user'->({'name'->'Charlie'} asDictionary)} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get object length from non-existent path"
	result := stick endpoint jsonObjLen: key path: (SjJsonPath root / 'nonexistent').
	
	"Result should be empty array for non-existent paths"
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonObjLenEmptyObject [
	| key value result |
	key := 'test:json:objlen:empty'.
	value := Dictionary new.
	
	"Set empty JSON object"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get object length of empty object"
	result := stick endpoint jsonObjLen: key.
	
	"Result should be 0 for empty object"
	self assert: result equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrLenBasic [
	| key value result |
	key := 'test:json:arrlen:basic'.
	value := {'items'->{1. 2. 3. 4. 5}} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get array length at nested path"
	result := stick endpoint jsonArrLen: key path: (SjJsonPath root / 'items').
	
	"Result should be array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 5
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrLenRootPath [
	| key value result |
	key := 'test:json:arrlen:root'.
	value := {1. 2. 3}.
	
	"Set JSON array at root"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get array length at root path using simple method"
	result := stick endpoint jsonArrLen: key.
	
	"Result should be the array length"
	self assert: result equals: 3
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrLenEmptyArray [
	| key value result |
	key := 'test:json:arrlen:empty'.
	value := {'data'->{}. 'count'->0} asDictionary.
	
	"Set JSON data with empty array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get empty array length"
	result := stick endpoint jsonArrLen: key path: (SjJsonPath root / 'data').
	
	"Result should be 0 for empty array"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrLenNonExistentKey [
	| key result |
	key := 'test:json:arrlen:nonexistent'.
	result := stick endpoint jsonArrLen: key.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrLenNonExistentPath [
	| key value result |
	key := 'test:json:arrlen:nonexistentpath'.
	value := {'user'->({'name'->'Alice'} asDictionary)} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get array length from non-existent path"
	result := stick endpoint jsonArrLen: key path: (SjJsonPath root / 'nonexistent').
	
	"Result should be empty array for non-existent paths"
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrLenNonArrayPath [
	| key value result |
	key := 'test:json:arrlen:nonarray'.
	value := {'data'->'not an array'. 'count'->3} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get array length from a non-array path (should return null)"
	result := stick endpoint jsonArrLen: key path: (SjJsonPath root / 'data').
	
	"Result should contain nil for non-array paths"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrAppendSingleValue [
	| key value result |
	key := 'test:json:arrappend:single'.
	value := {'items'->{1. 2. 3}} asDictionary.
	
	"Set JSON data with initial array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Append single value to array"
	result := stick endpoint jsonArrAppend: key path: (SjJsonPath root / 'items') values: {4}.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 4.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: result first equals: {1. 2. 3. 4}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrAppendMultipleValues [
	| key value result |
	key := 'test:json:arrappend:multiple'.
	value := {'numbers'->{1. 2}} asDictionary.
	
	"Set JSON data with initial array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Append multiple values to array"
	result := stick endpoint jsonArrAppend: key path: (SjJsonPath root / 'numbers') values: {3. 4. 5}.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 5.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'numbers').
	self assert: result first equals: {1. 2. 3. 4. 5}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrAppendMixedTypes [
	| key value result |
	key := 'test:json:arrappend:mixed'.
	value := {'data'->{1}} asDictionary.
	
	"Set JSON data with initial array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Append different types of values"
	result := stick endpoint jsonArrAppend: key path: (SjJsonPath root / 'data') values: {'hello'. true. nil. {'nested'->42} asDictionary}.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 5.
	
	"Verify the array content contains mixed types"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'data').
	self assert: result first size equals: 5.
	self assert: result first first equals: 1.
	self assert: result first second equals: 'hello'.
	self assert: result first third equals: true.
	self assert: result first fourth isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrAppendToEmptyArray [
	| key value result |
	key := 'test:json:arrappend:empty'.
	value := {'items'->{}} asDictionary.
	
	"Set JSON data with empty array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Append values to empty array"
	result := stick endpoint jsonArrAppend: key path: (SjJsonPath root / 'items') values: {'first'. 'second'}.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 2.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: result first equals: {'first'. 'second'}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrAppendToNonExistentArray [
	| key result |
	key := 'test:json:arrappend:nonexistent'.
	
	"Try to append to non-existent array - Redis returns null"
	result := stick endpoint jsonArrAppend: key path: (SjJsonPath root) values: {1. 2. 3}.
	
	"Should get null since the key doesn't exist"
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrAppendToNonArray [
	| key value result |
	key := 'test:json:arrappend:nonarray'.
	value := {'data'->'not an array'} asDictionary.
	
	"Set JSON data with non-array value"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to append to non-array - Redis returns array with null"
	result := stick endpoint jsonArrAppend: key path: (SjJsonPath root / 'data') values: {1. 2}.
	
	"Should get array with null since target is not an array"
	self assert: result isSequenceable.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexBasicSearch [
	| key value result |
	key := 'test:json:arrindex:basic'.
	value := {'items'->{1. 2. 3. 2. 4}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Search for existing value - should return first index"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 2.
	
	"Result should be index of first occurrence"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 1.
	
	"Search for value at beginning"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 1.
	self assert: result first equals: 0.
	
	"Search for value at end"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 4.
	self assert: result first equals: 4
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexNotFound [
	| key value result |
	key := 'test:json:arrindex:notfound'.
	value := {'numbers'->{1. 2. 3}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Search for non-existent value"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'numbers') value: 5.
	
	"Should return -1 for not found"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: -1
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexWithStartParameter [
	| key value result |
	key := 'test:json:arrindex:start'.
	value := {'items'->{1. 2. 3. 2. 4}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Search for value 2 starting from index 2 (should find second occurrence)"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 2 start: 2.
	
	"Result should be index of second occurrence"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 3.
	
	"Search for value 1 starting from index 1 (should not find)"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 1 start: 1.
	self assert: result first equals: -1
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexWithStartStopParameters [
	| key value result |
	key := 'test:json:arrindex:range'.
	value := {'data'->{1. 2. 3. 2. 4. 2. 5}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Search for value 2 in range [2, 4] (should find occurrence at index 3)"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'data') value: 2 start: 2 stop: 4.
	
	"Result should be index 3"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 3.
	
	"Search for value 2 in range [4, 6] (should find occurrence at index 5)"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'data') value: 2 start: 4 stop: 6.
	self assert: result first equals: 5.
	
	"Search for value 1 in range [2, 4] (should not find)"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'data') value: 1 start: 2 stop: 4.
	self assert: result first equals: -1
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexWithUsingBlock [
	| key value result |
	key := 'test:json:arrindex:using'.
	value := {'items'->{1. 2. 3. 2. 4}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Search using options block with start parameter"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 2 using: [:opts | opts start: 2].
	
	"Result should be second occurrence at index 3"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 3.
	
	"Search using options block with start and stop parameters"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'items') value: 2 using: [:opts | opts start: 0; stop: 2].
	
	"Should find first occurrence at index 1"
	self assert: result first equals: 1
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexEdgeCases [
	| key value result |
	key := 'test:json:arrindex:edge'.
	
	"Test with non-existent key"
	result := stick endpoint jsonArrIndex: key path: SjJsonPath root value: 1.
	self assert: result isNil.
	
	"Test with non-array value"
	value := {'data'->'not an array'} asDictionary.
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'data') value: 1.
	
	"Should get array with null for non-array paths"
	self assert: result isSequenceable.
	self assert: result first isNil.
	
	"Test with empty array"
	value := {'empty'->{}} asDictionary.
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'empty') value: 1.
	
	"Should return -1 for empty array"
	self assert: result first equals: -1
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrIndexStringValues [
	| key value result |
	key := 'test:json:arrindex:strings'.
	value := {'words'->{'hello'. 'world'. 'test'. 'hello'}} asDictionary.
	
	"Set JSON data with string array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Search for string value"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'words') value: 'hello'.
	
	"Result should be first occurrence"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 0.
	
	"Search for second occurrence using start parameter"
	result := stick endpoint jsonArrIndex: key path: (SjJsonPath root / 'words') value: 'hello' start: 1.
	self assert: result first equals: 3
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertSingleValue [
	| key value result |
	key := 'test:json:arrinsert:single'.
	value := {'items'->{1. 2. 4. 5}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Insert single value at index 2"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'items') index: 2 value: 3.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 5.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: result first equals: {1. 2. 3. 4. 5}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertMultipleValues [
	| key value result |
	key := 'test:json:arrinsert:multiple'.
	value := {'numbers'->{1. 5}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Insert multiple values at index 1"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'numbers') index: 1 values: {2. 3. 4}.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 5.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'numbers').
	self assert: result first equals: {1. 2. 3. 4. 5}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertAtBeginning [
	| key value result |
	key := 'test:json:arrinsert:beginning'.
	value := {'data'->{2. 3. 4}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Insert at beginning (index 0)"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'data') index: 0 value: 1.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 4.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'data').
	self assert: result first equals: {1. 2. 3. 4}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertAtEnd [
	| key value result |
	key := 'test:json:arrinsert:end'.
	value := {'items'->{1. 2. 3}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Insert at end (index equals array length)"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'items') index: 3 value: 4.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 4.
	
	"Verify the array content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: result first equals: {1. 2. 3. 4}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertMixedTypes [
	| key value result |
	key := 'test:json:arrinsert:mixed'.
	value := {'data'->{1. 'end'}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Insert different types of values"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'data') index: 1 values: {'hello'. true. nil. {'nested'->42} asDictionary}.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 6.
	
	"Verify the array content contains mixed types"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'data').
	self assert: result first size equals: 6.
	self assert: result first first equals: 1.
	self assert: result first second equals: 'hello'.
	self assert: result first third equals: true.
	self assert: result first fourth isNil.
	self assert: (result first at: 6) equals: 'end'
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertNegativeIndex [
	| key value result |
	key := 'test:json:arrinsert:negative'.
	value := {'items'->{1. 2. 3. 4. 5}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Insert using negative index (-1 means before last element)"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'items') index: -1 value: 99.
	
	"Result should be the new array length"
	self assert: result isSequenceable.
	self assert: result size equals: 1.
	self assert: result first equals: 6.
	
	"Verify the array content (99 should be inserted before last element)"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: result first equals: {1. 2. 3. 4. 99. 5}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertEdgeCases [
	| key value result |
	key := 'test:json:arrinsert:edge'.
	
	"Test with non-existent key"
	result := stick endpoint jsonArrInsert: key path: SjJsonPath root index: 0 value: 1.
	self assert: result isNil.
	
	"Test with non-array value"
	value := {'data'->'not an array'} asDictionary.
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'data') index: 0 value: 1.
	
	"Should get array with null for non-array paths"
	self assert: result isSequenceable.
	self assert: result first isNil.
	
	"Test with empty array"
	value := {'empty'->{}} asDictionary.
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'empty') index: 0 value: 'first'.
	
	"Should successfully insert into empty array"
	self assert: result first equals: 1.
	
	"Verify content"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'empty').
	self assert: result first equals: {'first'}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrInsertInvalidIndex [
	| key value result |
	key := 'test:json:arrinsert:invalid'.
	value := {'items'->{1. 2. 3}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to insert at invalid positive index (beyond array bounds + 1)"
	result := stick endpoint jsonArrInsert: key path: (SjJsonPath root / 'items') index: 10 value: 99.
	
	"Redis should return nil for invalid index"
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopBasic [
	| key value result afterPop |
	key := 'test:json:arrpop:basic'.
	value := {'items'->{1. 2. 3}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop from the array (should return array with last element: 3)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'items').
	self assert: result first equals: 3.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: afterPop first size equals: 2.
	self assert: afterPop first equals: {1. 2}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopRootPath [
	| key value result afterPop |
	key := 'test:json:arrpop:root'.
	value := {10. 20. 30}.
	
	"Set JSON data as root array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop from root array using simple method"
	result := stick endpoint jsonArrPop: key.
	self assert: result first equals: 30.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: afterPop first size equals: 2.
	self assert: afterPop first equals: {10. 20}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopWithIndex [
	| key value result afterPop |
	key := 'test:json:arrpop:index'.
	value := {'numbers'->{10. 20. 30. 40. 50}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop element at index 2 (third element: 30)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'numbers') index: 2.
	self assert: result first equals: 30.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'numbers').
	self assert: afterPop first size equals: 4.
	self assert: afterPop first equals: {10. 20. 40. 50}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopFirstElement [
	| key value result afterPop |
	key := 'test:json:arrpop:first'.
	value := {'letters'->{'a'. 'b'. 'c'}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop first element using index 0"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'letters') index: 0.
	self assert: result first equals: 'a'.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'letters').
	self assert: afterPop first size equals: 2.
	self assert: afterPop first equals: {'b'. 'c'}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopWithUsingBlock [
	| key value result afterPop |
	key := 'test:json:arrpop:using'.
	value := {'data'->{100. 200. 300. 400}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop element using options block"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'data') using: [ :opts | opts index: 1 ].
	self assert: result first equals: 200.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'data').
	self assert: afterPop first size equals: 3.
	self assert: afterPop first equals: {100. 300. 400}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopEmptyArray [
	| key value result |
	key := 'test:json:arrpop:empty'.
	value := {'empty'->{}} asDictionary.
	
	"Set JSON data with empty array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop from empty array (should return array with nil)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'empty').
	self assert: result equals: {nil}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopSingleElement [
	| key value result afterPop |
	key := 'test:json:arrpop:single'.
	value := {'single'->{42}} asDictionary.
	
	"Set JSON data with single element array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop the single element"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'single').
	self assert: result first equals: 42.
	
	"Verify the array is now empty"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'single').
	self assert: afterPop first isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopNonExistentKey [
	| key result |
	key := 'test:json:arrpop:nonexistent'.
	
	"Pop from non-existent key (should return nil)"
	result := stick endpoint jsonArrPop: key path: SjJsonPath root.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopNonExistentPath [
	| key value result |
	key := 'test:json:arrpop:nonexistentpath'.
	value := {'data'->{1. 2. 3}} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop from non-existent path (should return empty array)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'missing').
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopNonArrayPath [
	| key value result |
	key := 'test:json:arrpop:nonarray'.
	value := {'text'->'hello'. 'number'->42} asDictionary.
	
	"Set JSON data with non-array values"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to pop from non-array path (should return array with nil)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'text').
	self assert: result equals: {nil}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopOutOfRangeIndex [
	| key value result |
	key := 'test:json:arrpop:outofrange'.
	value := {'items'->{1. 2. 3}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop at out-of-range index (Redis rounds to array end - last element)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'items') index: 10.
	self assert: result first equals: 3
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopNegativeIndex [
	| key value result afterPop |
	key := 'test:json:arrpop:negative'.
	value := {'items'->{10. 20. 30. 40}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop using negative index (-1 should be last element)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'items') index: -1.
	self assert: result first equals: 40.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: afterPop first size equals: 3.
	self assert: afterPop first equals: {10. 20. 30}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrPopOutOfRangeNegativeIndex [
	| key value result afterPop |
	key := 'test:json:arrpop:outofrangenegative'.
	value := {'items'->{10. 20. 30. 40}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Pop using out-of-range negative index (Redis rounds to first element)"
	result := stick endpoint jsonArrPop: key path: (SjJsonPath root / 'items') index: -10.
	self assert: result first equals: 10.
	
	"Verify the array after pop"
	afterPop := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: afterPop first size equals: 3.
	self assert: afterPop first equals: {20. 30. 40}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimBasic [
	| key value result afterTrim |
	key := 'test:json:arrtrim:basic'.
	value := {'items'->{0. 1. 2. 3. 4. 5. 6. 7. 8. 9}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Trim array to keep elements from index 2 to 5"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'items') start: 2 stop: 5.
	self assert: result first equals: 4.
	
	"Verify the array after trim"
	afterTrim := stick endpoint jsonGet: key path: (SjJsonPath root / 'items').
	self assert: afterTrim first size equals: 4.
	self assert: afterTrim first equals: {2. 3. 4. 5}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimNegativeIndices [
	| key value result afterTrim |
	key := 'test:json:arrtrim:negative'.
	value := {'data'->{10. 20. 30. 40. 50. 60}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Trim using negative indices (-4 to -2)"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'data') start: -4 stop: -2.
	self assert: result first equals: 3.
	
	"Verify the array after trim"
	afterTrim := stick endpoint jsonGet: key path: (SjJsonPath root / 'data').
	self assert: afterTrim first size equals: 3.
	self assert: afterTrim first equals: {30. 40. 50}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimOutOfRange [
	| key value result afterTrim |
	key := 'test:json:arrtrim:outofrange'.
	value := {'numbers'->{1. 2. 3. 4. 5}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Trim with stop index beyond array length"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'numbers') start: 2 stop: 10.
	self assert: result first equals: 3.
	
	"Verify the array after trim (should keep elements from index 2 to end)"
	afterTrim := stick endpoint jsonGet: key path: (SjJsonPath root / 'numbers').
	self assert: afterTrim first equals: {3. 4. 5}
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimInvalidRange [
	| key value result afterTrim |
	key := 'test:json:arrtrim:invalid'.
	value := {'test'->{10. 20. 30}} asDictionary.
	
	"Set JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Trim with start > stop (should result in empty array)"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'test') start: 5 stop: 2.
	self assert: result first equals: 0.
	
	"Verify the array is now empty"
	afterTrim := stick endpoint jsonGet: key path: (SjJsonPath root / 'test').
	self assert: afterTrim first isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimEmptyArray [
	| key value result |
	key := 'test:json:arrtrim:empty'.
	value := {'empty'->{}} asDictionary.
	
	"Set JSON data with empty array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Trim empty array"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'empty') start: 0 stop: 5.
	self assert: result first equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimNonExistentPath [
	| key value result |
	key := 'test:json:arrtrim:nonexistent'.
	value := {'data'->{1. 2. 3}} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to trim non-existent path (returns empty collection)"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'missing') start: 0 stop: 2.
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimNonArrayPath [
	| key value result |
	key := 'test:json:arrtrim:nonarray'.
	value := {'text'->'hello'. 'number'->42} asDictionary.
	
	"Set JSON data with non-array values"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to trim non-array path (returns collection with nil)"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'text') start: 0 stop: 2.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonArrTrimSingleElement [
	| key value result afterTrim |
	key := 'test:json:arrtrim:single'.
	value := {'item'->{42}} asDictionary.
	
	"Set JSON data with single element array"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Trim single element array to keep just that element"
	result := stick endpoint jsonArrTrim: key path: (SjJsonPath root / 'item') start: 0 stop: 0.
	self assert: result first equals: 1.
	
	"Verify the array still contains the element"
	afterTrim := stick endpoint jsonGet: key path: (SjJsonPath root / 'item').
	self assert: afterTrim first equals: {42}
]

{ #category : 'tests' }
RsJsonTest >> testJsonStrLenRootPath [
	| key result |
	key := 'test:json:strlen:root'.
	
	"Set string at root path"
	stick endpoint jsonSet: key path: SjJsonPath root value: 'Hello, World!'.
	
	"Get string length at root path using simple method"
	result := stick endpoint jsonStrLen: key.
	self assert: result equals: 13
]

{ #category : 'tests' }
RsJsonTest >> testJsonStrLenBasic [
	| key value result |
	key := 'test:json:strlen:basic'.
	value := {'message'->'Test String'. 'nested'->({'text'->'Smalltalk'} asDictionary)} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Get string length at nested path"
	result := stick endpoint jsonStrLen: key path: (SjJsonPath root / 'message').
	self assert: result first equals: 11.
	
	"Test nested path"
	result := stick endpoint jsonStrLen: key path: (SjJsonPath root / 'nested' / 'text').
	self assert: result first equals: 9
]

{ #category : 'tests' }
RsJsonTest >> testJsonStrLenEmptyString [
	| key result |
	key := 'test:json:strlen:empty'.
	
	"Set empty string at root path"
	stick endpoint jsonSet: key path: SjJsonPath root value: ''.
	
	"Test jsonStrLen: for empty string"
	result := stick endpoint jsonStrLen: key.
	self assert: result equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonStrLenNonExistentKey [
	| result |
	
	"Test with non-existent key"
	result := stick endpoint jsonStrLen: 'nonexistent:key'.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonStrLenNonExistentPath [
	| key value result |
	key := 'test:json:strlen:nonexistent:path'.
	value := {'message'->'Hello'} asDictionary.
	
	"Set data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Test with non-existent path"
	result := stick endpoint jsonStrLen: key path: (SjJsonPath root / 'nonexistent' / 'path').
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonStrLenNonStringPath [
	| key value result |
	key := 'test:json:strlen:nonstring'.
	value := {'data'->42. 'count'->3} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get string length from a non-string path (should return null)"
	result := stick endpoint jsonStrLen: key path: (SjJsonPath root / 'data').
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumIncrByBasic [
	| key value result |
	key := 'test:json:numincrby:basic'.
	value := {'counter'->10. 'score'->100. 'temperature'->25.5} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Increment integer value"
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'counter') increment: 5.
	self assert: result first equals: 15.
	
	"Verify the increment worked"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'counter').
	self assert: result first equals: 15.
	
	"Increment floating point value"
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'temperature') increment: 2.5.
	self assert: result first equals: 28.0.
	
	"Verify the float increment worked"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'temperature').
	self assert: result first equals: 28.0
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumIncrByNegativeIncrement [
	| key value result |
	key := 'test:json:numincrby:negative'.
	value := {'balance'->100. 'points'->50} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Decrement with negative increment"
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'balance') increment: -25.
	self assert: result first equals: 75.
	
	"Verify the decrement worked"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'balance').
	self assert: result first equals: 75
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumIncrByNonExistentKey [
	| key result |
	key := 'test:json:numincrby:nonexistent'.
	
	"Try to increment value in non-existent key"
	result := stick endpoint jsonNumIncrBy: key path: SjJsonPath root increment: 10.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumIncrByNonExistentPath [
	| key value result |
	key := 'test:json:numincrby:nonexistentpath'.
	value := {'existing'->5} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to increment non-existent path"
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'nonexistent') increment: 10.
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumIncrByNonNumericType [
	| key value result |
	key := 'test:json:numincrby:nonnumeric'.
	value := {'name'->'Alice'. 'data'->{1. 2. 3}. 'active'->true} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to increment string value (should return nil)"
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'name') increment: 1.
	self assert: result first isNil.
	
	"Try to increment array value (should return nil)"
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'data') increment: 1.
	self assert: result first isNil.
	
	"Try to increment boolean value (should return nil)"  
	result := stick endpoint jsonNumIncrBy: key path: (SjJsonPath root / 'active') increment: 1.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumMultByBasic [
	| key value result |
	key := 'test:json:nummultby:basic'.
	value := {'price'->10. 'rate'->2.5. 'quantity'->4} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Multiply integer value"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'price') multiplier: 3.
	self assert: result first equals: 30.
	
	"Verify the multiplication worked"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'price').
	self assert: result first equals: 30.
	
	"Multiply floating point value"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'rate') multiplier: 1.5.
	self assert: result first equals: 3.75.
	
	"Verify the float multiplication worked"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'rate').
	self assert: result first equals: 3.75
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumMultByNegativeMultiplier [
	| key value result |
	key := 'test:json:nummultby:negative'.
	value := {'balance'->100. 'factor'-> -2} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Multiply with negative multiplier"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'balance') multiplier: -0.5.
	self assert: result first equals: -50.0.
	
	"Verify the negative multiplication worked"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'balance').
	self assert: result first equals: -50.0
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumMultByZeroMultiplier [
	| key value result |
	key := 'test:json:nummultby:zero'.
	value := {'value'->42} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Multiply by zero"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'value') multiplier: 0.
	self assert: result first equals: 0.
	
	"Verify the result is zero"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'value').
	self assert: result first equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumMultByNonExistentKey [
	| key result |
	key := 'test:json:nummultby:nonexistent'.
	
	"Try to multiply value in non-existent key"
	result := stick endpoint jsonNumMultBy: key path: SjJsonPath root multiplier: 2.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumMultByNonExistentPath [
	| key value result |
	key := 'test:json:nummultby:nonexistentpath'.
	value := {'existing'->5} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to multiply non-existent path"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'nonexistent') multiplier: 2.
	self assert: result isEmpty
]

{ #category : 'tests' }
RsJsonTest >> testJsonNumMultByNonNumericType [
	| key value result |
	key := 'test:json:nummultby:nonnumeric'.
	value := {'name'->'Alice'. 'data'->{1. 2. 3}. 'active'->true} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to multiply string value (should return nil)"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'name') multiplier: 2.
	self assert: result first isNil.
	
	"Try to multiply array value (should return nil)"
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'data') multiplier: 2.
	self assert: result first isNil.
	
	"Try to multiply boolean value (should return nil)"  
	result := stick endpoint jsonNumMultBy: key path: (SjJsonPath root / 'active') multiplier: 2.
	self assert: result first isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonDelBasic [
	| key value result |
	key := 'test:json:del:basic'.
	value := {'name'->'John'. 'age'->30. 'city'->'Tokyo'} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Delete a specific path"
	result := stick endpoint jsonDel: key path: (SjJsonPath root / 'age').
	self assert: result equals: 1.
	
	"Verify the path was deleted"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: {'name'->'John'. 'city'->'Tokyo'} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonDelEntireKey [
	| key value result |
	key := 'test:json:del:entire'.
	value := {'data'->'test'} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Delete the entire key (root path)"
	result := stick endpoint jsonDel: key path: SjJsonPath root.
	self assert: result equals: 1.
	
	"Verify the key was deleted"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonDelNonExistentPath [
	| key value result |
	key := 'test:json:del:nonexistent'.
	value := {'name'->'Alice'} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to delete non-existent path"
	result := stick endpoint jsonDel: key path: (SjJsonPath root / 'missing').
	self assert: result equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonDelNonExistentKey [
	| key result |
	key := 'test:json:del:nokey'.
	
	"Try to delete from non-existent key"
	result := stick endpoint jsonDel: key path: SjJsonPath root.
	self assert: result equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonTypeBasic [
	| key value result |
	key := 'test:json:type:basic'.
	value := {
		'name'->'Alice'.
		'age'->25.
		'active'->true.
		'scores'->{85. 92. 78}.
		'profile'->({'city'->'Paris'} asDictionary).
		'empty'->nil
	} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Test root type"
	result := stick endpoint jsonType: key.
	self assert: result equals: 'object'.
	
	"Test string type - returns array with enhanced path syntax"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'name').
	self assert: result equals: #('string').
	
	"Test number type - Redis returns 'integer' for whole numbers"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'age').
	self assert: result equals: #('integer').
	
	"Test boolean type"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'active').
	self assert: result equals: #('boolean').
	
	"Test array type"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'scores').
	self assert: result equals: #('array').
	
	"Test object type"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'profile').
	self assert: result equals: #('object').
	
	"Test null type"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'empty').
	self assert: result equals: #('null')
]

{ #category : 'tests' }
RsJsonTest >> testJsonTypeNonExistentKey [
	| key result |
	key := 'test:json:type:nokey'.
	
	"Try to get type from non-existent key"
	result := stick endpoint jsonType: key.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonTypeNonExistentPath [
	| key value result |
	key := 'test:json:type:nopath'.
	value := {'name'->'Bob'} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Try to get type from non-existent path"
	result := stick endpoint jsonType: key path: (SjJsonPath root / 'missing').
	"Redis returns empty array for non-existent paths with enhanced path syntax"
	self assert: result equals: #()
]

{ #category : 'tests' }
RsJsonTest >> testJsonDelKeyOnly [
	| key value result |
	key := 'test:json:del:keyonly'.
	value := {'data'->'test'} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Delete the entire key using jsonDel: key (no path)"
	result := stick endpoint jsonDel: key.
	self assert: result equals: 1.
	
	"Verify the key was deleted"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonClearArray [
	| key value result |
	key := 'test:json:clear:array'.
	value := {1. 2. 3. 4}.
	
	"Set array data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Clear the array"
	result := stick endpoint jsonClear: key path: SjJsonPath root.
	self assert: result equals: 1.
	
	"Verify the array is now empty"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assertCollection: result first equals: #()
]

{ #category : 'tests' }
RsJsonTest >> testJsonClearObject [
	| key value result |
	key := 'test:json:clear:object'.
	value := {'name'->'Alice'. 'age'->30. 'city'->'Tokyo'} asDictionary.
	
	"Set object data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Clear the object"
	result := stick endpoint jsonClear: key path: SjJsonPath root.
	self assert: result equals: 1.
	
	"Verify the object is now empty"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: Dictionary new
]

{ #category : 'tests' }
RsJsonTest >> testJsonClearKeyOnly [
	| key value result |
	key := 'test:json:clear:keyonly'.
	value := {'items'->{1. 2. 3}. 'count'->3} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Clear using key-only method"
	result := stick endpoint jsonClear: key.
	self assert: result equals: 1.
	
	"Verify the root is now empty object"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: Dictionary new
]

{ #category : 'tests' }
RsJsonTest >> testJsonClearNestedPath [
	| key value result |
	key := 'test:json:clear:nested'.
	value := {'user'->({'name'->'Bob'. 'settings'->({'theme'->'dark'. 'notifications'->true} asDictionary)} asDictionary). 'data'->{1. 2. 3}} asDictionary.
	
	"Set nested data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Clear nested object"
	result := stick endpoint jsonClear: key path: (SjJsonPath root / 'user' / 'settings').
	self assert: result equals: 1.
	
	"Verify nested object was cleared but parent structure remains"
	result := stick endpoint jsonGet: key path: (SjJsonPath root / 'user').
	self assert: result first equals: {'name'->'Bob'. 'settings'->(Dictionary new)} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonClearNonExistentKey [
	| key result |
	key := 'test:json:clear:nonexistent'.
	
	"Try to clear non-existent key"
	result := stick endpoint jsonClear: key path: SjJsonPath root.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonClearScalarValue [
	| key value result |
	key := 'test:json:clear:scalar'.
	value := 42.
	
	"Set scalar data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Clear scalar (should set to 0 for numbers)"
	result := stick endpoint jsonClear: key path: SjJsonPath root.
	self assert: result equals: 1.
	
	"Verify the scalar was set to 0"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonForgetBasic [
	| key value result |
	key := 'test:json:forget:basic'.
	value := {'name'->'John'. 'age'->30} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Forget (delete) a specific path"
	result := stick endpoint jsonForget: key path: (SjJsonPath root / 'age').
	self assert: result equals: 1.
	
	"Verify the path was deleted"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result first equals: {'name'->'John'} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonForgetKeyOnly [
	| key value result |
	key := 'test:json:forget:keyonly'.
	value := {'data'->'test'} asDictionary.
	
	"Set JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	
	"Forget (delete) the entire key using key-only method"
	result := stick endpoint jsonForget: key.
	self assert: result equals: 1.
	
	"Verify the key was deleted"
	result := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: result isNil
]

{ #category : 'tests' }
RsJsonTest >> testJsonForgetNonExistentKey [
	| key result |
	key := 'test:json:forget:nonexistent'.
	
	"Try to forget non-existent key"
	result := stick endpoint jsonForget: key.
	self assert: result equals: 0
]

{ #category : 'tests' }
RsJsonTest >> testJsonForgetEqualsJsonDel [
	| key value delResult forgetResult |
	key := 'test:json:forget:equals:del'.
	value := {'test'->'data'} asDictionary.
	
	"Test that jsonForget and jsonDel return identical results"
	"Set data and delete with jsonDel"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	delResult := stick endpoint jsonDel: key path: (SjJsonPath root / 'test').
	
	"Set data again and delete with jsonForget"
	stick endpoint jsonSet: key path: SjJsonPath root value: value.
	forgetResult := stick endpoint jsonForget: key path: (SjJsonPath root / 'test').
	
	"Both should return identical results"
	self assert: delResult equals: forgetResult
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeBasic [
	| key originalValue mergeValue mergeResult finalResult |
	key := 'test:json:merge:basic'.
	originalValue := {'name'->'Alice'. 'age'->25. 'city'->'Paris'} asDictionary.
	mergeValue := {'age'->30. 'country'->'France'} asDictionary.
	
	"Set initial JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: originalValue.
	
	"Merge with new data - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: SjJsonPath root value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify merged result"
	finalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: finalResult first equals: {'name'->'Alice'. 'age'->30. 'city'->'Paris'. 'country'->'France'} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeNullDeletion [
	| key originalValue mergeValue mergeResult finalResult |
	key := 'test:json:merge:null'.
	originalValue := {'name'->'Bob'. 'age'->35. 'city'->'London'. 'active'->true} asDictionary.
	mergeValue := {'age'->nil. 'status'->'inactive'} asDictionary.
	
	"Set initial JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: originalValue.
	
	"Merge with null value to delete 'age' field - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: SjJsonPath root value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify 'age' was deleted and 'status' was added"
	finalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: finalResult first equals: {'name'->'Bob'. 'city'->'London'. 'active'->true. 'status'->'inactive'} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeNestedPath [
	| key originalValue mergeValue mergeResult finalResult |
	key := 'test:json:merge:nested'.
	originalValue := {'user'->({'name'->'Charlie'. 'preferences'->({'theme'->'dark'. 'lang'->'en'} asDictionary)} asDictionary)} asDictionary.
	mergeValue := {'lang'->'fr'. 'notifications'->true} asDictionary.
	
	"Set initial nested JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: originalValue.
	
	"Merge at nested path - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: (SjJsonPath root / 'user' / 'preferences') value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify nested merge result"
	finalResult := stick endpoint jsonGet: key path: (SjJsonPath root / 'user' / 'preferences').
	self assert: finalResult first equals: {'theme'->'dark'. 'lang'->'fr'. 'notifications'->true} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeArrayReplacement [
	| key originalValue mergeValue mergeResult finalResult |
	key := 'test:json:merge:array'.
	originalValue := {'items'->{1. 2. 3}. 'metadata'->({'count'->3} asDictionary)} asDictionary.
	mergeValue := {'items'->{4. 5. 6. 7}} asDictionary.
	
	"Set initial JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: originalValue.
	
	"Merge with new array (should replace entire array) - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: SjJsonPath root value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify array was completely replaced"
	finalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: finalResult first equals: {'items'->{4. 5. 6. 7}. 'metadata'->({'count'->3} asDictionary)} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeTypeConflict [
	| key originalValue mergeValue mergeResult finalResult |
	key := 'test:json:merge:conflict'.
	originalValue := {'data'->{1. 2. 3}. 'count'->3} asDictionary.
	mergeValue := {'data'->({'converted'->true} asDictionary)} asDictionary.
	
	"Set initial JSON data with array"
	stick endpoint jsonSet: key path: SjJsonPath root value: originalValue.
	
	"Merge with different type (array -> object) - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: SjJsonPath root value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify type conflict resolved by replacement"
	finalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: finalResult first equals: {'data'->({'converted'->true} asDictionary). 'count'->3} asDictionary
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeNonExistentKey [
	| key mergeValue mergeResult finalResult |
	key := 'test:json:merge:nonexistent'.
	mergeValue := {'created'->true. 'name'->'New'} asDictionary.
	
	"Merge to non-existent key (should create new key) - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: SjJsonPath root value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify key was created with merge value"
	finalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: finalResult first equals: mergeValue
]

{ #category : 'tests' }
RsJsonTest >> testJsonMergeNonExistentPath [
	| key originalValue mergeValue mergeResult finalResult |
	key := 'test:json:merge:nonexistentpath'.
	originalValue := {'existing'->'data'} asDictionary.
	mergeValue := {'created'->true} asDictionary.
	
	"Set initial JSON data"
	stick endpoint jsonSet: key path: SjJsonPath root value: originalValue.
	
	"Merge to non-existent nested path - should return 'OK'"
	mergeResult := stick endpoint jsonMerge: key path: (SjJsonPath root / 'newpath') value: mergeValue.
	self assert: mergeResult equals: 'OK'.
	
	"Verify nested path was created"
	finalResult := stick endpoint jsonGet: key path: SjJsonPath root.
	self assert: finalResult first equals: {'existing'->'data'. 'newpath'->mergeValue} asDictionary
]

