*RediStick-Stream
createStreamEntryFrom: rawEntryCollection 
	rawEntryCollection ifNil: [ ^#() ].
	^ rawEntryCollection collect: [ :each | RsStreamEntry fromOrderedCollection: each ]