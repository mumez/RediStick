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
- Multiple path JSON GET: `jsonGet:paths:` for retrieving multiple JSON paths at once
- JSON SET with options: `jsonSet:path:value:using:` supporting `ifNotExists`, `ifAlreadyExists`
- JSON GET with pretty-formatting: `jsonGet:path:using:` supporting INDENT, NEWLINE, SPACE options
- JSON object key retrieval: `jsonObjKeys:` and `jsonObjKeys:path:` for getting object keys
- Comprehensive test coverage in `RsJsonTest` class

### Implementation Details
- `RsJsonSetOptions`: Handles NX (if not exists) and XX (if already exists) modes
- `RsJsonGetOptions`: Handles pretty-formatting with indent, newline, and space options
- Smart result handling: Returns parsed JSON objects by default, raw strings when formatting options are used
- Multiple path support: Returns dictionary with paths as keys, arrays as values
- JSON.OBJKEYS support: Returns nested collections with object keys, handles edge cases (nil for non-objects, empty for non-existent paths)
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

[stick endpoint jsonXXX ] on: Error do: [:ex | ex description]. "returns error description if error occures"
```