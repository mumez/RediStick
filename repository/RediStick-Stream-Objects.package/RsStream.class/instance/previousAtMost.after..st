reading
previousAtMost: count after: latestMessageId
	^ self endpoint xRevRange: self name from: latestMessageId count: count