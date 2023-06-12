# How to use with RediSearch 

RediStick supports [RediSearch](https://redis.io/docs/stack/search/) - a full-text search extension for Redis.

## Installation

RediSearch is not included in Redis by default.
Since RediSearch is a part of [Redis Stack](https://redis.io/docs/stack/), the easiest way to start RediSearch-enabled redis is using [official docker image](https://hub.docker.com/r/redis/redis-stack).

```bash
docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 -v /local-data/:/data redis/redis-stack:latest
```




```smalltalk

Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/repository';
  load: #('Core' 'Search').
```


A channel is a class that represents a particular subject in RediStick pubsub mechanism.  It supports the publication of messages with a specific subject and also supports the receipt of messages on that subject.
You can define a new channel class by subclassing `RsRedisPubsubChannel`.

```smalltalk
RsRedisPubsubChannel subclass: #RsGreetingPubsubChannel
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'RediStick-Demo'
```

At first, you need to override #channelName class method for indicating the channel name. 

```smalltalk
RsGreetingPubsubChannel class >> channelName
	^#greeting
```

Then, override #handlePublished: instance method for handling received messages.

```smalltalk
RsGreetingPubsubChannel >> handlePublished: greeting
	greeting inspect

```

## Publish

Now, you can publish a greeting  message on that subject.

```smalltalk
channel := RsRedisPubsubChannel named: #greeting.
channel publish: 'hello'
```

Nothing happens at this stage. You need to subscribe to the topic, before receiving messages.


## Subscribe

All channel subscriptions are kept in SubscriptionManager. By default, channels are automatically subscribed to when the image starts. But you can also manually renew the subscriptions by:

```smalltalk
RsRedisSubscriptionManager reset
```

Now, if you evaluate `channel publish: 'hello'` again,  the greeting channel's  #handlePublished: will be called. And you can see that the 'hello' string inspector is open.

Off course, you can publish messages from other images. Enjoy!

## Auto-recovery of subscriptions

Sometimes, your subscriptions may be lost on various network problems.

RediStick internally uses PingChannel to detect subscription failures. If there are no received ping-messages for about 30 seconds, SubscriptionManager will automatically subscribe to the registered channels again.

This feature minimizes the possibility of losing messages.

