reading
contentsReversedNextFrom: fromMessageId count: count
	^ self endpoint xRevRange: self name nextFrom: fromMessageId count: count