private connection
onClosing
	pubsub ifTrue: [self releasePubsub].
	super onClosing
	