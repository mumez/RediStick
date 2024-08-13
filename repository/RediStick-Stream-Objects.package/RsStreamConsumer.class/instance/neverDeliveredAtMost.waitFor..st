reading
neverDeliveredAtMost: count waitFor: milliseconds
	^ self endpoint
		  xRead: self name
		  id: RsStreamMessageId newest
		  blocking: milliseconds
		  count: count