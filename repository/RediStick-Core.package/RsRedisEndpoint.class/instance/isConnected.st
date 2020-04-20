testing
isConnected
	^self socketStream notNil and: [ self socketStream isConnected ]