tests
testGoodAuthentifiaction 
	self initializeStick.
	stick endpoint auth: 'goodPassword'.
	self assert: (self endpoint ping) equals: #PONG 