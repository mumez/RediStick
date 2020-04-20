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