subscribing
subscribeChannels
	self subscriberRedis subscribe: RsRedisPubsubChannel channelNames callback: [ :msg | self dispatchPublishedMessage: msg ]