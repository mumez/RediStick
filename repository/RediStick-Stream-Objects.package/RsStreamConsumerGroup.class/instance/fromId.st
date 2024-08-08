accessing
fromId

	^ fromId ifNil: [ fromId := RsStreamMessageId newest ]