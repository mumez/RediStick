tests
testWrongAuthentifiaction
	self initializeStick.
	self
		should: [ stick endpoint auth: 'wrongPassword' ]
		raise: RsGenericError.
	self should: [ self endpoint ping ] raise: RsGenericError.
	self
		should: [ self endpoint exists: 'aRandomKey' ]
		raise: RsGenericError