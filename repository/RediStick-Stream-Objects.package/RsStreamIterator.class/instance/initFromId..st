initialization
initFromId: fromIdLikeThing
	fromIdLikeThing ifNil: [ ^ fromId := '' ].
	fromId := fromIdLikeThing asStreamMessageId