event-handling
handlePublished: payload
	| replyReceived |
	replyReceived := (sentToken = payload).
	replyReceived ifFalse: [ 
		self resetSubscriptions
	]
	
	