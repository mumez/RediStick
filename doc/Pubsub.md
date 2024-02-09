# Pubsub with RediStick

RediStick provides a simle API for utilizing the pubsub feature of Redis.

## Basic API

The most basic way to use pubsub is as follows:

```smalltalk
"Subscriber"
subRedis := RsRediStick targetUrl: 'sync://localhost'.
subRedis connect.
subRedis onError: [ :ex | subRedis destroy ].
subRedis endpoint subscribe: {#'hello'} callback: [ :msg | msg payload ifNotNil: [ :p | (STON fromString: p) inspect]]. "Subscribe to #hello channel." 
```

```smalltalk
"Publisher"
pubRedis := RsRedisProxy pubsub.
pubRedis publish: #'hello' message: (STON toString: Time now). "You can see inspector will open on Subscriber side."
```

Please note that after subscription, the subscriber enters a mode for incoming channel messages. It ignores normal redis commands until you send #unsubscribe: to the client.

```smalltalk
subRedis endpoint unsubscribe: {#'hello'}. "Exits the subscription mode. Now this stick accepts normal commands again"
```

This behavior is documented in [SUBSCRIBE](https://redis.io/commands/subscribe/) section.

Since managing pub/sub connections properly can be a bit cumbersome, there are high-level classes available: RsRedisSubscriptionManager and RsRedisPubsubChannel. You can use these to work with the pubsub feature more easily!

## Defining a channel class

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
