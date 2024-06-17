reading
newest: count waitFor: milliseconds
	^ self endpoint xRead: self name id: RsStreamMessageId newest blocking: milliseconds