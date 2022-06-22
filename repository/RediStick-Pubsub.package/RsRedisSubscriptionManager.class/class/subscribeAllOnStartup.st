accessing
subscribeAllOnStartup
	^ subscribeAllOnStartup ifNil: [ subscribeAllOnStartup := true ]