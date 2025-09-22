# Working with JSON in RediStick

[RediStick](https://github.com/mumez/RediStick) supports [RedisJSON](https://redis.io/docs/latest/develop/data-types/json/) - a JSON data type for Redis.

RedisJSON is included in Redis 8.0 and later. For earlier versions, you can use Redis with JSON module support.

## Installation

### Installing RediStick JSON packages

You can install RediStick JSON packages into Pharo (or GemStone/S).

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Json').
```

If you need tests:

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Json' 'JsonTests').
```

## Basic Usage

### Setting up Connection

```smalltalk
stick := RsRediStick targetUrl: 'sync://localhost'.
stick connect.
```

### Basic JSON Operations

#### Setting and Getting JSON Data

```smalltalk
"Set a JSON object"
user := {'name'->'John'. 'age'->30. 'city'->'Tokyo'} asDictionary.
stick endpoint jsonSet: 'user:123' path: SjJsonPath root value: user.

"Get the JSON object"
result := stick endpoint jsonGet: 'user:123' path: SjJsonPath root.
result value. "Returns the parsed dictionary"
```

#### Understanding RsJsonGetResult

Most JSON query operations (GET, length operations) return `RsJsonGetResult` wrapper objects that provide consistent access to results and metadata:

```smalltalk
"Get JSON data"
result := stick endpoint jsonGet: 'user:123' path: SjJsonPath root.

"Access the actual value"
user := result value.      "Returns the first/single result"
data := result values.     "Returns all results as array"

"Check result state"
result isInvalidKey.       "true if key doesn't exist"
result hasValue.           "true if key exists (regardless of content)"
result isEmpty.            "true if key exists but no values returned"

"Access metadata"
result key.                "Returns the Redis key that was queried"
result path.               "Returns the JSON path that was used"
```

#### Working with JSON Paths

```smalltalk
"Set nested JSON data"
profile := {'user'->({'name'->'Alice'. 'profile'->({'age'->25. 'active'->true} asDictionary)} asDictionary)} asDictionary.
stick endpoint jsonSet: 'profile:456' path: SjJsonPath root value: profile.

"Get specific nested values"
name := stick endpoint jsonGet: 'profile:456' path: (SjJsonPath root / 'user' / 'name').
name value. "Returns 'Alice'"

age := stick endpoint jsonGet: 'profile:456' path: (SjJsonPath root / 'user' / 'profile' / 'age').
age value. "Returns 25"
```

#### Multiple Path Queries

```smalltalk
"Get multiple paths at once"
paths := {
    SjJsonPath root / 'user' / 'name'.
    SjJsonPath root / 'user' / 'profile' / 'age'.
    SjJsonPath root / 'user' / 'profile' / 'active'
}.

results := stick endpoint jsonGet: 'profile:456' paths: paths.
results do: [:result |
    Transcript show: result path asString, ': ', result value asString; cr].
```

## Advanced Features

### Conditional Operations

```smalltalk
"Set only if key doesn't exist"
stick endpoint jsonSet: 'new:key' path: SjJsonPath root value: {'status'->'new'} asDictionary using: [:opts |
    opts ifNotExists].

"Set only if key already exists"
stick endpoint jsonSet: 'existing:key' path: SjJsonPath root value: {'status'->'updated'} asDictionary using: [:opts |
    opts ifAlreadyExists].
```

### Pretty Formatting

```smalltalk
"Get JSON with pretty formatting"
formatted := stick endpoint jsonGet: 'profile:456' path: SjJsonPath root using: [:opts |
    opts indent: String tab.
    opts newLine: String lf.
    opts space: ' '].
"Returns formatted JSON string instead of parsed object"
```

### Type and Structure Operations

```smalltalk
"Get JSON value type - returns RsJsonGetResult wrapper"
result := stick endpoint jsonType: 'user:123' path: (SjJsonPath root / 'age').
result value. "Returns 'integer'"
```

### String Operations

```smalltalk
"Get string length - returns RsJsonGetResult wrapper"
result := stick endpoint jsonStrLen: 'user:123' path: (SjJsonPath root / 'name').
length := result value.  "Get the length value"

"Append to string"
stick endpoint jsonStrAppend: 'user:123' path: (SjJsonPath root / 'name') value: ' Doe'.
```

### Numeric Operations

```smalltalk
"Increment numeric values - returns RsJsonGetResult wrapper"
result := stick endpoint jsonNumIncrBy: 'user:123' path: (SjJsonPath root / 'age') increment: 1.
newAge := result value.  "Get the new value"

"Multiply numeric values - returns RsJsonGetResult wrapper"
result := stick endpoint jsonNumMultBy: 'user:123' path: (SjJsonPath root / 'age') multiplier: 2.
doubled := result value.  "Get the multiplied value"
```

### Array Operations

```smalltalk
"Working with JSON arrays"
data := {'items'->{1. 2. 3}. 'tags'->{'red'. 'blue'}} asDictionary.
stick endpoint jsonSet: 'data:789' path: SjJsonPath root value: data.

"Get array length - returns RsJsonGetResult wrapper"
result := stick endpoint jsonArrLen: 'data:789' path: (SjJsonPath root / 'items').
length := result value.  "Get the array length"

"Append to array"
stick endpoint jsonArrAppend: 'data:789' path: (SjJsonPath root / 'items') values: {4. 5}.

"Insert at specific index"
stick endpoint jsonArrInsert: 'data:789' path: (SjJsonPath root / 'items') index: 1 values: {10}.

"Find value index in array - returns RsJsonGetResult wrapper"
result := stick endpoint jsonArrIndex: 'data:789' path: (SjJsonPath root / 'items') value: 3.
index := result value.  "Get the index (-1 if not found)"

"Pop element from array - returns RsJsonGetResult wrapper"
result := stick endpoint jsonArrPop: 'data:789' path: (SjJsonPath root / 'items').
popped := result value.  "Get the popped element"

"Trim array to specific range"
stick endpoint jsonArrTrim: 'data:789' path: (SjJsonPath root / 'items') start: 0 stop: 2.
```

### Object Operations

```smalltalk
"Get object keys - returns RsJsonGetResult wrapper"
result := stick endpoint jsonObjKeys: 'user:123' path: SjJsonPath root.
keys := result value.  "Get the array of keys"

"Get number of object fields - returns RsJsonGetResult wrapper"
result := stick endpoint jsonObjLen: 'user:123' path: SjJsonPath root.
fieldCount := result value.  "Get the field count"
```

### Boolean Operations

```smalltalk
"Toggle boolean values - returns RsJsonGetResult wrapper"
result := stick endpoint jsonToggle: 'profile:456' path: (SjJsonPath root / 'user' / 'profile' / 'active').
result value. "Returns true/false"

"Toggle at root path"
stick endpoint jsonSet: 'flag:test' path: SjJsonPath root value: false.
result := stick endpoint jsonToggle: 'flag:test'.
result value. "Returns true"
```

### JSON Merge Operations

```smalltalk
"RFC7396 compliant JSON merge"
original := {'user'->({'name'->'John'. 'age'->30} asDictionary). 'active'->true} asDictionary.
stick endpoint jsonSet: 'merge:test' path: SjJsonPath root value: original.

"Merge patch - updates existing fields and adds new ones"
patch := {'user'->({'age'->31. 'city'->'Tokyo'} asDictionary). 'premium'->true} asDictionary.
result := stick endpoint jsonMerge: 'merge:test' path: SjJsonPath root value: patch.

final := stick endpoint jsonGet: 'merge:test' path: SjJsonPath root.
"Result: {'user'->{'name'->'John'. 'age'->31. 'city'->'Tokyo'}. 'active'->true. 'premium'->true}"
```

### Batch Operations

#### Batch SET Operations

```smalltalk
"Using fluent interface"
stick endpoint jsonMSetUsing: [:multiSet |
    multiSet
        key: 'user:1' path: SjJsonPath root value: {'name'->'Alice'. 'age'->25} asDictionary;
        key: 'user:2' path: SjJsonPath root value: {'name'->'Bob'. 'age'->30} asDictionary;
        key: 'user:3' path: SjJsonPath root value: {'name'->'Charlie'. 'status'->'active'} asDictionary].

"Using RsJsonMultiSetValues directly"
multiSet := RsJsonMultiSetValues new
    key: 'batch:1' path: SjJsonPath root value: {'count'->1} asDictionary;
    key: 'batch:2' path: SjJsonPath root value: {'count'->2} asDictionary;
    yourself.
stick endpoint jsonMSet: multiSet.
```

#### Batch GET Operations

```smalltalk
"Get from multiple keys at root path"
results := stick endpoint jsonMGet: {'user:1'. 'user:2'. 'user:3'}.
results do: [:result |
    result hasValue ifTrue: [
        Transcript show: result key, ': ', result value asString; cr
    ] ifFalse: [
        Transcript show: result key, ': (no data)'; cr
    ]].

"Get specific path from multiple keys"
results := stick endpoint jsonMGet: {'user:1'. 'user:2'} path: (SjJsonPath root / 'name').
results collect: [:result | result value]. "Returns array of names"
```

## Result Handling

### RsJsonGetResult Wrapper

All JSON GET operations return `RsJsonGetResult` wrapper objects that provide metadata and state checking:

```smalltalk
result := stick endpoint jsonGet: 'some:key' path: SjJsonPath root.

"Check result state"
result isInvalidKey. "true if key doesn't exist"
result hasValue. "true if key exists (regardless of value)"
result isEmpty. "true if key exists but value is empty"

"Access metadata"
result key. "Returns the original key"
result path. "Returns the original path"

"Access values"
result value. "Returns first value or nil"
result first. "Alias for value"
result values. "Returns array of values or nil if invalid key"
```

## Error Handling

```smalltalk
"Handle potential errors"
[
    result := stick endpoint jsonGet: 'nonexistent:key' path: SjJsonPath root.
    result isInvalidKey ifTrue: [
        Transcript show: 'Key does not exist'; cr
    ] ifFalse: [
        Transcript show: 'Value: ', result value asString; cr
    ]
] on: Error do: [:error |
    Transcript show: 'Redis error: ', error messageText; cr
].
```

## Performance Tips

1. **Use batch operations** when working with multiple keys
2. **Specify exact paths** instead of retrieving entire documents when possible
3. **Use conditional operations** to avoid unnecessary overwrites
4. **Consider using JSON merge** for partial document updates
5. **Cache path objects** when using the same paths repeatedly:

```smalltalk
"Cache commonly used paths"
userNamePath := SjJsonPath root / 'user' / 'name'.
userAgePath := SjJsonPath root / 'user' / 'age'.

"Reuse in multiple operations"
name := stick endpoint jsonGet: 'profile:123' path: userNamePath.
age := stick endpoint jsonGet: 'profile:123' path: userAgePath.
```

## Cleanup Operations

```smalltalk
"Clear JSON containers - this will remove all data from the key"
stick endpoint jsonClear: 'user:123' path: SjJsonPath root.
```

## References

- [RedisJSON Overview](https://redis.io/docs/latest/develop/data-types/json/)
- [RedisJSON Commands](https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/json/commands/)
- [SJsonPath](https://github.com/mumez/SJsonPath)
- [RFC7396 - JSON Merge Patch](https://tools.ietf.org/rfc/rfc7396.txt)