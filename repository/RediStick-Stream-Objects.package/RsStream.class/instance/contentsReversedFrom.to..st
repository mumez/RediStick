reading
contentsReversedFrom: fromMessageId to: toMessageId
	^ self endpoint xRevRange: self name start: fromMessageId end: toMessageId 