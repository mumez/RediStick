accessing
connectionKeeper
	connectionKeeper ifNil: [ 
		connectionKeeper := self createConnectionKeeper.
	].
	^connectionKeeper