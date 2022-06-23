subscribing
subscribeChannels: channelNames
	self subscriber endpoint subscribe: channelNames callback: [ :msg | self dispatchPublishedMessage: msg ]