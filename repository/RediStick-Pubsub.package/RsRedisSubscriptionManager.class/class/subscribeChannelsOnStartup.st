accessing
subscribeChannelsOnStartup
	^ subscribeChannelsOnStartup ifNil: [ subscribeChannelsOnStartup := true ]