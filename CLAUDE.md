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
- JSON operations support options: `jsonSet:path:value:using:` with `ifNotExists`/`ifAlreadyExists`
- JSON GET supports pretty-formatting with `jsonGet:path:using:` (INDENT, NEWLINE, SPACE options)

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

## Key Classes to Understand
- `RsRedisEndpoint`: Main Redis command interface
- `RsRediStick`: Connection management and auto-reconnection
- `BaselineOfRediStick`: Package structure and dependencies
- Stream objects: `RsStream`, `RsStreamInfo`, etc. for Redis Streams
- Connection pool: `RsRedisConnectionPool`, `RsRedisProxy`
- JSON classes: `RsJsonSetOptions`, `RsJsonGetOptions` for JSON operation options

## Redis JSON Implementation Status

### Completed Features
- Basic JSON operations: `jsonGet:path:`, `jsonSet:path:value:`
- **Automatic JSON conversion**: JSON SET operations automatically convert Smalltalk objects to JSON strings
- Multiple path JSON GET: `jsonGet:paths:` for retrieving multiple JSON paths at once
- JSON SET with options: `jsonSet:path:value:using:` supporting `ifNotExists`, `ifAlreadyExists`
- JSON GET with pretty-formatting: `jsonGet:path:using:` supporting INDENT, NEWLINE, SPACE options
- JSON object key retrieval: `jsonObjKeys:` and `jsonObjKeys:path:` for getting object keys
- JSON object length: `jsonObjLen:` and `jsonObjLen:path:` for getting object field count
- Comprehensive test coverage in `RsJsonTest` class

### Implementation Details
- **Automatic value conversion**: `jsonSet:path:value:options:` automatically converts Smalltalk objects (dictionaries, arrays, numbers, booleans, nil) to JSON strings using `toJsonString:` helper method
- **Idiomatic Smalltalk syntax**: Tests and usage examples use native Smalltalk dictionaries (`{'key'->'value'} asDictionary`) instead of hardcoded JSON strings
- `RsJsonSetOptions`: Handles NX (if not exists) and XX (if already exists) modes
- `RsJsonGetOptions`: Handles pretty-formatting with indent, newline, and space options
- Smart result handling: Returns parsed JSON objects by default, raw strings when formatting options are used
- Multiple path support: Returns dictionary with paths as keys, arrays as values
- JSON.OBJKEYS support: Returns nested collections with object keys, handles edge cases (nil for non-objects, empty for non-existent paths)
- JSON.OBJLEN support: Returns object field count, returns nil for non-objects, handles nested paths with array results
- Safe JSON parsing with `safeParseJson:` helper method
- Integration with SJsonPath for JSON path operations

### References
- Overview: https://redis.io/docs/latest/develop/data-types/json/
- Commands: https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/json/commands/
- Valkey API: https://valkey.io/commands/#json


# Test tips for debug in pharo

```smalltalk
| stick |
"You can instantiate a stick for test and send messages" 
stick := RsRediStick targetUrl: RsRedisTestCase urlString.
stick connect.
stick endpoint select: RsRedisTestCase dbIndex.

"JSON operations now support automatic conversion from Smalltalk objects"
stick endpoint jsonSet: 'test:key' path: SjJsonPath root value: {'name'->'Alice'. 'age'->30} asDictionary.

[stick endpoint jsonXXX ] on: Error do: [:ex | ex description]. "returns error description if error occurs"
```

# Development Tips and Troubleshooting

## Package Import and Testing Workflow

### 1. Tonel File Validation
Always validate `.st` files after creation/modification:
```bash
# Use smalltalk-validator MCP tool
mcp__smalltalk-validator__validate_tonel_smalltalk_from_file: '/path/to/file.st'
```

### 2. Package Import to Pharo
Use absolute paths for reliable package imports:
```smalltalk
"Import packages using MCP smalltalk-interop"
mcp__smalltalk-interop__import_package: 'RediStick-Json' path: '/home/ume/git/RediStick/src'
mcp__smalltalk-interop__import_package: 'RediStick-Json-Tests' path: '/home/ume/git/RediStick/src'
```

### 3. Method Verification
Check if new methods are loaded correctly:
```smalltalk
"Verify method exists"
RsRedisEndpoint canUnderstand: #jsonArrLen:
RsRedisEndpoint canUnderstand: #jsonArrAppend:path:values:
```

### 4. Test Execution Patterns
Count and run specific test groups:
```smalltalk
"Count tests by pattern"
| result |
result := RsJsonTest suite tests select: [ :each | each selector beginsWith: 'testJsonArrLen' ].
result size

"Run tests and get results"
| suite results |
suite := TestSuite new.
RsJsonTest suite tests select: [ :each | each selector beginsWith: 'testJsonArrAppend' ] thenDo: [ :test | suite addTest: test ].
results := suite run.
'Passed: ', results passedCount asString, ', Failed: ', results failureCount asString, ', Errors: ', results errorCount asString
```

### 5. Redis Behavior Testing
Test actual Redis behavior before writing assertions:
```smalltalk
| stick |
stick := RsRediStick targetUrl: RsRedisTestCase urlString.
stick connect.
stick endpoint select: RsRedisTestCase dbIndex.

"Test edge cases to understand actual Redis responses"
stick endpoint jsonArrAppend: 'nonexistent' path: SjJsonPath root values: {1. 2. 3}. "=> nil"
stick endpoint jsonArrAppend: 'nonarray' path: (SjJsonPath root / 'stringfield') values: {1}. "=> [nil]"
```

### 6. Common Pitfalls
- **Eval Syntax**: Use correct variable declaration: `| var |` not just `result := ...`
- **Error Testing**: Redis often returns `nil` or `[nil]` instead of throwing errors
- **Package Reimport**: Always reimport packages after file modifications
- **Path Handling**: Use `SjJsonPath root` for root paths, not raw strings
- **Test Database**: Always use `RsRedisTestCase dbIndex` to avoid conflicts

### 7. Debugging Failed Tests
When tests fail:
1. Run individual test methods to isolate issues
2. Test the actual Redis behavior in isolation
3. Check if error expectations match Redis reality
4. Verify test data setup is correct
5. Ensure proper cleanup between tests