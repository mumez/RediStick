factory
restoreSubscriptions
	(subscriber notNil and: [ subscriber isEnded not ]) ifTrue: [ ^self ].
	self prepareSubscriber.
	self subscribeChannels