subscribing
subscribeChannels
	self subscriber endpoint subscribe: RsRedisPubsubChannel channelNames callback: [ :msg | self dispatchPublishedMessage: msg ]