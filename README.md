# RediStick
A Redis client for Pharo using Stick auto-reconnection layer

Many parts are borrowed from RedisClient.

However RediStick use [Stick](https://github.com/mumez/Stick) for supporting auto reconnection.

```smalltalk

stick := RsRediStick targetUrl: 'sync://localhost'.
stick connect.
stick beSticky. "Auto reconnect when server is not accessible"
stick onError: [ :e | e pass ].
stick endpoint info.
stick endpoint get: 'a'.
stick endpoint set: 'a' value: 999.

```

## Installation

Default (Core only):

```smalltalk

Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load.
```

With Connection-Pool package:

```smalltalk

Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load: #('Core' 'ConnectionPool').
```

## how to setUp test environement

in this repository there is a redis.conf file , redis use it for initialisation

```bash
docker run -p 6379:6379 \
-v /my/Absolute/Path/To/redis.conf:/etc/redis/redis.conf \ # copy from my redis.conf file store in this repository to a file store in the docker container 
-v /home/user/data:/data \ 
redis-server /usr/local/etc/redis/redis.conf #execute redis-server with redis configuration file
```
