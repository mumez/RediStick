# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RediStick is a Redis client for Pharo Smalltalk (and GemStone/S) that uses the Stick auto-reconnection layer. The project is structured as a modular Smalltalk package with multiple optional components for different Redis features.

## Development Commands

### Running Tests
```bash
# Run all tests using smalltalkci
smalltalkci -s Pharo64-13

# Run specific test groups via Metacello
# Tests are defined in .smalltalk.ston with groups: Tests, StreamTests, StreamObjectsTests, SearchTests, JsonTests
```

### CI/CD
- Tests run automatically on push via GitHub Actions
- Uses smalltalkci with Redis Stack service
- Supports Pharo 11, 12, and 13
- Test configuration in `.smalltalk.ston`

## Architecture

### Core Components
- **RsRedisEndpoint**: Main Redis client class extending SkSyncStickEndpoint
- **RsRediStick**: Connection management with auto-reconnection via Stick framework
- **BaselineOfRediStick**: Metacello baseline defining package dependencies and groups

### Package Structure
- `RediStick-Core`: Base Redis client functionality
- `RediStick-Connection-Pool`: Connection pooling support
- `RediStick-Pubsub`: Redis Pub/Sub messaging
- `RediStick-Stream`/`RediStick-Stream-Objects`: Redis Streams support
- `RediStick-Json`: Redis JSON module support (RedisJSON)
- `RediStick-Search`: RediSearch full-text search support
- `*-Tests` packages: Test suites for each module

### Extension Pattern
Extensions to core classes are used for modular features:
- `RsRedisEndpoint` extensions in Json, Stream, Search packages
- Example: `RsRedisEndpoint >> jsonGet:path:` in RediStick-Json package

### Dependencies
- **Stick**: Auto-reconnection framework (github://mumez/Stick/src)
- **SJsonPath**: JSON path support for JSON module (github://mumez/SJsonPath:main/src)

## Installation Groups
Available Metacello groups:
- `Core`: Basic Redis functionality
- `ConnectionPool`: Connection pooling
- `Pubsub`: Publish/Subscribe
- `Stream`/`StreamObjects`: Redis Streams
- `Json`: Redis JSON support
- `Search`: RediSearch support

## File Format
- Source code in Tonel format (`.st` files)
- Package definitions in `package.st` files
- Class extensions use `.extension.st` suffix
- Test classes follow `*Test.class.st` naming convention

## Redis JSON Implementation Status

### Completed Features
**Basic Operations:**
- `jsonGet:path:`, `jsonSet:path:value:` - Basic JSON get/set operations
- `jsonDel:path:`, `jsonForget:path:` - Delete operations (forget is alias for del)
- `jsonType:path:` - Get JSON value type
- `jsonClear:path:` - Clear containers (arrays/objects)

**Advanced GET/SET:**
- `jsonGet:paths:` - Multiple path retrieval
- `jsonGet:path:using:` - Pretty-formatting with INDENT, NEWLINE, SPACE options
- `jsonSet:path:value:using:` - Conditional set with `ifNotExists`, `ifAlreadyExists`
- Automatic Smalltalk object to JSON conversion

**String Operations:**
- `jsonStrLen:path:` - String length
- `jsonStrAppend:path:value:` - String append

**Numeric Operations:**
- `jsonNumIncrBy:path:increment:` - Increment numeric values
- `jsonNumMultBy:path:multiplier:` - Multiply numeric values

**Array Operations:**
- `jsonArrLen:path:` - Array length
- `jsonArrAppend:path:values:` - Append to arrays
- `jsonArrInsert:path:index:values:` - Insert at specific index
- `jsonArrIndex:path:value:` - Find value index (with start/stop parameters)
- `jsonArrPop:path:index:` - Pop element at index
- `jsonArrTrim:path:start:stop:` - Trim array to range

**Object Operations:**
- `jsonObjKeys:path:` - Get object keys
- `jsonObjLen:path:` - Get object field count

**Document Management:**
- `jsonMerge:path:value:` - RFC7396 compliant JSON merge operations
- Support for partial document updates, null deletion, type conflict resolution

**Boolean Operations:**
- `jsonToggle:`, `jsonToggle:path:` - Boolean value toggling operations
- Returns boolean arrays for intuitive Smalltalk usage
- `jsonToggleRaw:path:` - Raw 0/1 values for advanced use cases

**Batch Operations:**
- `jsonMSet:` - Batch JSON SET operations using RsJsonMultiSetValues
- `jsonMSetUsing:` - Convenient block syntax for batch operations
- `jsonMGet:keys:` - Batch JSON GET operations from multiple keys
- `jsonMGet:keys:path:` - Batch JSON GET from specific paths across multiple keys
- `RsJsonMultiSetValues` - Fluent interface for building batch SET commands

### Implementation Details
- **Automatic conversion**: Smalltalk objects (dictionaries, arrays, numbers, booleans, nil) automatically converted to JSON
- **Smart result handling**: Parsed JSON objects by default, raw strings with formatting options
- **Option classes**: `RsJsonSetOptions`, `RsJsonGetOptions`, `RsJsonArrOptions` for operation parameters
- **Safe parsing**: `safeParseJson:` helper method for robust JSON handling
- **SJsonPath integration**: Full JSON path support for all operations
- **RFC7396 compliance**: JSON Merge Patch standard for efficient document updates

### Test Coverage
- 128 comprehensive tests in `RsJsonTest` class (final implementation)
- Covers all operations, edge cases, error conditions
- Tests for both single-path and multi-path operations
- RFC7396 compliance testing for merge operations
- Boolean toggle operations with comprehensive edge case coverage
- Batch operation testing with fluent interface validation
- Batch retrieval testing with MGET operations
- Array path testing with SJsonPath `@` indexing syntax
- Mixed existing/non-existing key handling in batch operations

### Implementation Progress
- **Overall Completion**: 100% (29/29 tasks completed)
- **Implemented Commands**: 75+ JSON methods across all major operation categories
- **Current Phase**: Complete - all Redis JSON API commands implemented
- **Completed Features**:
  - All core JSON operations (GET, SET, DEL, TYPE, CLEAR)
  - Advanced operations (arrays, strings, numbers, objects, merge)
  - Boolean manipulation with intuitive API
  - Batch operations (SET and GET) with fluent interface
  - Complete MGET batch retrieval functionality

### References
- [Redis JSON Overview](https://redis.io/docs/latest/develop/data-types/json/)
- [Redis JSON Commands](https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/json/commands/)
- [Valkey JSON API](https://valkey.io/commands/#json)

## Development and Testing Workflow

### Package Development
```smalltalk
# Validate Tonel files after modifications
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/path/to/file.st'

# Import packages (use absolute paths, reimport after changes)
mcp__smalltalk-interop__import_package: 'RediStick-Json' path: '/home/ume/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-Json-Tests' path: '/home/ume/git/RediStick/src'

# Run tests
mcp__smalltalk-interop__run_class_test: 'RsJsonTest'
```

### Interactive Testing and Debugging
```smalltalk
| stick |
"Direct Redis testing - bypasses test runner issues"
stick := RsRediStick targetUrl: RsRedisTestCase urlString.
stick connect.
stick endpoint select: RsRedisTestCase dbIndex.

"Test JSON operations directly"
stick endpoint jsonSet: 'test:key' path: SjJsonPath root value: {'name'->'Alice'. 'age'->30} asDictionary.
stick endpoint jsonGet: 'test:key' path: (SjJsonPath root / 'name').

"Error handling"
[stick endpoint jsonSomeOperation: parameters] on: Error do: [:ex | ex description].
```

### Test Debugging Strategy
**When individual tests fail:**
```smalltalk
"Debug specific test method"
| test |
test := RsJsonTest new.
test setUp.
[test testMethodName] on: Error do: [:ex | ex description]
```

**For serialization errors (STONWriterError, NeoJSONMappingNotFound):**
- Use proper parentheses in nested `asDictionary` expressions to avoid syntax precedence issues
- Test components individually with direct Redis behavior testing
- Example proper nested dictionary syntax:
```smalltalk
"Concise nested dictionary literals with proper parentheses:"
value := {'user'->({'name'->'Bob'. 'settings'->({'theme'->'dark'. 'notifications'->true} asDictionary)} asDictionary). 'data'->{1. 2. 3}} asDictionary.
```

### Test Patterns
```smalltalk
"Count and run specific test subsets"
| count suite results |
count := RsJsonTest suite tests select: [ :each | each selector beginsWith: 'testJsonArr' ].
count size.

"Run specific test group"
suite := TestSuite new.
RsJsonTest suite tests select: [ :each | each selector beginsWith: 'testJsonClear' ] 
  thenDo: [ :test | suite addTest: test ].
results := suite run.
'Passed: ', results passedCount asString, ', Failed: ', results failureCount asString
```

### Common Pitfalls
- **Eval Syntax**: Always declare variables: `| var |`
- **Error Expectations**: Redis often returns `nil` or `[nil]` instead of throwing errors
- **Path Handling**: Use `SjJsonPath root` for root paths
- **Test Database**: Always use `RsRedisTestCase dbIndex` to avoid conflicts
- **Array Assertions**: Use `assertCollection:equals:` for better error messages
- **Package Reimport**: Always reimport packages after file modifications

### Key Classes to Understand
- `RsRedisEndpoint`: Main Redis command interface with JSON extensions
- `RsRediStick`: Connection management and auto-reconnection
- `BaselineOfRediStick`: Package structure and dependencies
- JSON option classes: `RsJsonSetOptions`, `RsJsonGetOptions`, `RsJsonArrOptions`
- Stream objects: `RsStream`, `RsStreamInfo` for Redis Streams
- Connection pool: `RsRedisConnectionPool`, `RsRedisProxy`

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.