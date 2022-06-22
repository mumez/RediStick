system startup
startUp: resuming
	resuming ifTrue: [
		3 seconds wait.
		self subscribeAllAndStart.
	]