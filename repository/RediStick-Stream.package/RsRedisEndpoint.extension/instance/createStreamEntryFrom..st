*RediStick-Stream
createStreamEntryFrom: rawEntryCollection 
	^ rawEntryCollection collect: [ :each | RsStreamEntry fromOrderedCollection: each ]