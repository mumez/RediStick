initialization
initCurrentId: fromIdLikeThing
	currentId := fromIdLikeThing ifNotNil: [ fromIdLikeThing asStreamMessageId ].