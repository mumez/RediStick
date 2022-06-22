class initialization
initDefault
	default ifNotNil: [ 
		default unsubscribeAllAndStop.
	].
	default := nil