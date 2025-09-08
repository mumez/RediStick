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

