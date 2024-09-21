reading
pendingsNoAckAtMost: count after: latestMessageId on: consumerName
	^ self wrapAsAcceptableEntries: (self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName
		  using: [ :opts |
			  opts
				  noAck;
				  count: count ])