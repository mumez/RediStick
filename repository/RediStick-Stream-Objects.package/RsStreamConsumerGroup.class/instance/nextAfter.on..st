reading
nextAfter: latestMessageId on: consumerName
	^ self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName