subscribing
subscribeChannels
	self subscriberRedis endpoint subscribe: RsRedisPubsubChannel channelNames callback: [ :msg | self dispatchPublishedMessage: msg ]