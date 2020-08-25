tests
testWrongAuthentifiaction
	self initializeStick.
	self
		should: [ stick endpoint auth: 'wrongPassword' ]
		raise: RsGenericError.
	self should: [ stick endpoint ping ] raise: RsGenericError.
	self
		should: [ stick endpoint exists: 'aRandomKey' ]
		raise: RsGenericError.
	self sendGoodPassword