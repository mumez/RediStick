reading
neverDeliveredNoAckAtMost: count waitFor: milliseconds on: consumerName
	^ self wrapAsAcceptableEntries: (self endpoint
			   xGroupRead: self streamName
			   id: RsStreamMessageId neverDelivered
			   group: self name
			   consumer: consumerName
			   using: [ :opts |
				   opts
					   noAck: true;
					   blocking: milliseconds;
					   count: count ])