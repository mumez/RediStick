accessing
fromId

	^ fromId ifNil: [ fromId := RsStreamMessageId zero ]