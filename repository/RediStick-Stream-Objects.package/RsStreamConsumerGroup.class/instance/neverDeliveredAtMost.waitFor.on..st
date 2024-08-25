reading
neverDeliveredAtMost: count waitFor: milliseconds on: consumerName
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id:  RsStreamMessageId neverDelivered
		  group: self name
		  consumer: consumerName
		  blocking: milliseconds
		  count: count)