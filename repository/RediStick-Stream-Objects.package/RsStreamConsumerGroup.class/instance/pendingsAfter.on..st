reading
pendingsAfter: latestMessageId on: consumerName
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName)