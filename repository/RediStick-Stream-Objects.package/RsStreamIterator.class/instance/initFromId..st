initialization
initFromId: fromIdLikeThing
	fromId := fromIdLikeThing
		          ifNil: [ RsStreamMessageId zero ]
		          ifNotNil: [ fromIdLikeThing asStreamMessageId ].
	currentId := fromId