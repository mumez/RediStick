system startup
startUp: resuming
	resuming ifFalse: [ ^ self ].
	3 seconds wait.
	self subscribeChannelsOnStartup ifTrue: [ 
		RsRedisPubsubChannel initialize.
		self default startUp ]