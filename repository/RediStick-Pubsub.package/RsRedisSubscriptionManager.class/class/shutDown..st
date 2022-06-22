system startup
shutDown: quitting
	quitting ifTrue: [
		self unsubscribeAllAndStop.
		default := nil.
	]