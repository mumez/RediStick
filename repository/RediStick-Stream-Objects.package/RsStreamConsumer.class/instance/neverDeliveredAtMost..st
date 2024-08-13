reading
neverDeliveredAtMost: count
	^ self endpoint
		  xRead: self name
		  id: RsStreamMessageId newest
		  count: count