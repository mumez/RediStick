# RediStick

[![CI](https://github.com/mumez/RediStick/actions/workflows/main.yml/badge.svg)](https://github.com/mumez/RediStick/actions/workflows/main.yml)

A Redis client for Pharo (and GemStone/S) using Stick auto-reconnection layer

Many parts are borrowed from RedisClient.

However RediStick use [Stick](https://github.com/mumez/Stick) for supporting auto reconnection.

## Installation

### Default (Core only)

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load.
```

### With Connection-Pool package

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Core' 'ConnectionPool').
```

### With Pubsub package

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Core' 'Pubsub').
```

### With Stream package

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('StreamObjects').
```

<details>
<summary>
stream low-level API only
</summary>

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Core' 'Stream').
```

</details>

### With Search package

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Core' 'Search').
```

## Sample Code

### Basic usage

```smalltalk
stick := RsRediStick targetUrl: 'sync://localhost'.
stick connect.

stick beSticky. "Auto reconnect when server is not accessible"
stick beSwitchy: 'sync://otherhost'. "Or connect to the secondary server"
stick onError: [ :e | e pass ]. "Or just pass an error (not reconnect) - mainly for debug"

stick endpoint info.
stick endpoint get: 'a'.
stick endpoint set: 'a' value: 999.
```

### Using a connection pool with a wrapper class

```smalltalk
RsRedisConnectionPool primaryUrl: 'sync://localhost:6379'.
redis := RsRedisProxy of: #client1.
redis at: 'a'.
redis at: 'a' put: 999.
```

In this example, the default connection pool is implicitly used through RedisProxy.

### Using Pubsub channel

RediStick provides a channel class for using redis pubsub API very easily.

Please read [Pubsub.md](./doc/Pubsub.md).

### Using Stream

RediStick supports [Redis Streams](https://redis.io/docs/data-types/streams/) - distributed event streaming API.

Please read [Stream.md](./doc/Stream.md).

### Using Search

RediStick supports [RediSearch](https://redis.io/docs/stack/search/) - a full-text search extension for Redis.

Please read [Search.md](./doc/Search.md).
