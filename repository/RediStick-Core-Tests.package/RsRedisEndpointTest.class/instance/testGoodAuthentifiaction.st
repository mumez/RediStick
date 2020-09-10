tests
testGoodAuthentifiaction 
	self initializeStick.
	stick endpoint auth: 'goodPassword'.
	self assert: (stick endpoint ping) equals: #PONG 