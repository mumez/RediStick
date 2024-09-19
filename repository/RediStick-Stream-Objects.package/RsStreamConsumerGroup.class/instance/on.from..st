initialization
on: aStream from: idLikeThing
	stream := aStream.
	idLikeThing ifNil: [ ^ self fromFirst ].
	self initMessageId: idLikeThing