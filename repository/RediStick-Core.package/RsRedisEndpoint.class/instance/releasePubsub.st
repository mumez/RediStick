initialize-release
releasePubsub
	[ self unsubscribe: self channels]
		on: Error
		do: [ :ex |  ].
	listener ifNotNil: [ listener terminate ].
	self exitPubsub.
	listener := nil.