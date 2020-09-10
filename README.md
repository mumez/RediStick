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



The test cases includes authentication testing. 
You will need to setup a redis database with those configuration.

you should add ```requirepass``` entry to your Redis configuration file (redis.conf).
```
requirepass goodPassword
```

in this repository there is a file *redistick-testing.conf* that containing setup information for testing.

### setup with redis-server command

and run the server with configuration file 
```
redis-server redis.conf
```
For convenience, you can just use 'redistick-testing.conf' file located this directory.
```
redis-server redistick-testing.conf
```

### setup with docker

```bash
docker run -p 6379:6379 \
-v /my/Absolute/Path/To/redistick-testing.conf:/etc/redis/redis.conf \ # copy from my redis.conf file store in this repository to a file store in the docker container 
-v /home/user/data:/data \ 
redis-server /usr/local/etc/redis/redis.conf #execute redis-server with redis configuration file
```

