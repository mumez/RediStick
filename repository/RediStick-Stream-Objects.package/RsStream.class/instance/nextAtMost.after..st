reading
nextAtMost: count after: latestMessageId
	^ self endpoint xRead: self name id: latestMessageId count: count