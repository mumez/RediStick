reading
previousAtMost: count after: latestMessageId
	^ self endpoint xRevRange: self name nextFrom: latestMessageId count: count