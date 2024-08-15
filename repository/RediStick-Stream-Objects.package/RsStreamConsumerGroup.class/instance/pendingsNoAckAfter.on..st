reading
pendingsNoAckAfter: latestMessageId on: consumerName
	^ self endpoint
		  xGroupRead: self streamName
		  id: latestMessageId
		  group: self name
		  consumer: consumerName
		  using: [ :opts | opts noAck ]