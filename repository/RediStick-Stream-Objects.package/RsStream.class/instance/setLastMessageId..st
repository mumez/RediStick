accessing
setLastMessageId: messageId
	^ self endpoint xSet: self name lastId: messageId