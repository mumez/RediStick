system startup
startUp: resuming
	resuming ifFalse: [ ^ self ].
	3 seconds wait.
	self subscribeChannelsOnStartup ifTrue: [ 
		self refreshChannelsAndStart ]