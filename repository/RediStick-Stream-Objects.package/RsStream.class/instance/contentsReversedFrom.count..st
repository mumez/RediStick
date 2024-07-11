reading
contentsReversedFrom: fromMessageId count: count
	^ self endpoint xRevRange: self name from: fromMessageId count: count