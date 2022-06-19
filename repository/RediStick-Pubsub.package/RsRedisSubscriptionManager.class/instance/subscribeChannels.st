subscribing
subscribeChannels
	self subscriberRediStick endpoint subscribe: RsRedisPubsubChannel channelNames callback: [ :msg | self dispatchPublishedMessage: msg ]