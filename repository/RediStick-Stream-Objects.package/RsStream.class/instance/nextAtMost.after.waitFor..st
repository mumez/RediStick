reading
nextAtMost: count after: latestMessageId waitFor: milliseconds
	^ self endpoint
		  xRead: self name
		  id: latestMessageId
		  blocking: milliseconds
		  count: count