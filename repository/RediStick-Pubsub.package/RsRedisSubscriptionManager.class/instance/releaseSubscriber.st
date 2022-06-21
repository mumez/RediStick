releasing
releaseSubscriber
	self subscriber ifNotNil: [ :stick | 
		stick destroy.
		self subscriber: nil ]