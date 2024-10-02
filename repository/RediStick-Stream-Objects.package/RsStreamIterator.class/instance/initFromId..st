initialization
initFromId: fromIdLikeThing
	fromId := fromIdLikeThing ifNotNil: [ fromIdLikeThing asStreamMessageId ].