reading
contentsReversedFrom: fromMessageId count: count
	^ self endpoint xRevRange: self name nextFrom: fromMessageId count: count