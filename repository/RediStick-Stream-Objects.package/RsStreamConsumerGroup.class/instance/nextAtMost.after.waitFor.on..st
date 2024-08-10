reading
nextAtMost: count after: latestMessageId waitFor: milliseconds on: consumerName
	^ self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName
		  blocking: milliseconds
		  count: count