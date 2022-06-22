system startup
startUp: resuming
	(resuming and: [self subscribeAllOnStartup]) ifTrue: [
		3 seconds wait.
		self subscribeAllAndStart.
	]