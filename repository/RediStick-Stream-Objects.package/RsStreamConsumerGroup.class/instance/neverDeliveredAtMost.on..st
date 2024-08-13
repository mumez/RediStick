reading
neverDeliveredAtMost: count on: consumerName
	^ self endpoint
		  xGroupRead: self streamName
		  id:  RsStreamMessageId neverDelivered
		  group: self name
		  consumer: consumerName
		  count: count