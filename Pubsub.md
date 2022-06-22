# Pubsub with RediStick

RediStick provides a simle API for utilizing pubsub feature of Redis.

## Defining a channel class

A channel is a class that represents a particular subject in RediStick pubsub mechanism.  It supports the publication of messages with a specific subject and also supports the receipt of messages on that subject.
You can define a new channel class by subclassing `RsRedisPubsubChannel`.

```
RsRedisPubsubChannel subclass: #RsGreetingPubsubChannel
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'RediStick-Demo'
```

At first, you need to override #channelName class method for indicating the channel name. 

```
RsGreetingPubsubChannel class >> channelName
	^#greeting
```

Then, override #handlePublished: instance method for handling received messages.

```
RsGreetingPubsubChannel >> handlePublished: greeting
	greeting inspect

```

## Publish

Now, you can publish a greeting  message on that subject.

```
channel := RsRedisPubsubChannel named: #greeting.
channel publish: 'hello'
```

Nothing happens at this stage. You need to subscribe to the topic, before receiving messages.


## Subscribe
All channel subscriptions are kept in SubscriptionManager. You can refresh the subscriptions by:

`RsRedisSubscriptionManager reset`

Now, if you evaluate `channel publish: 'hello'` again,  the greeting channel's  #handlePublished: will be called. And you can see that the 'hello' string inspector is open.

Off course, you can publish messages from other images. Enjoy!

## Auto-recovery of subscriptions

Sometimes, your subscriptions may be lost on various network problems.

RediStick internally uses PingChannel to detect subscription failures. If there are no received ping-messages for about 30 seconds, SubscriptionManager will automatically subscribe to the registered channels again.

This feature minimizes the possibility of losing messages.



