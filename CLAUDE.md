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
# Tests are defined in .smalltalk.ston with groups: Tests, StreamTests, StreamObjectsTests, SearchTests
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

## Key Classes to Understand
- `RsRedisEndpoint`: Main Redis command interface
- `RsRediStick`: Connection management and auto-reconnection
- `BaselineOfRediStick`: Package structure and dependencies
- Stream objects: `RsStream`, `RsStreamInfo`, etc. for Redis Streams
- Connection pool: `RsRedisConnectionPool`, `RsRedisProxy`

## Plan
Add RedisJson support.
- Overview:
https://redis.io/docs/latest/develop/data-types/json/

- API:
https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/json/commands/

- API:
https://valkey.io/commands/#json

