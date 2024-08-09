initialization
on: aStream from: idLikeThing
	stream := aStream.
	streamName := aStream name.
	idLikeThing ifNil: [ ^ self fromFirst ].
	self initMessageId: idLikeThing