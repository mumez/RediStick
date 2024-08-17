reading
neverDeliveredAtMost: count on: consumerName
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id:  RsStreamMessageId neverDelivered
		  group: self name
		  consumer: consumerName
		  count: count)