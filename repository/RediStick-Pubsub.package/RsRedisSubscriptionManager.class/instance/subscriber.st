accessing
subscriber
	subscriber ifNil: [ self prepareSubscriber ].
	^ subscriber