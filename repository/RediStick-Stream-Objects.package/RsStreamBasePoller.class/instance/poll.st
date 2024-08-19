actions
poll
	| received |
	self isConnected ifFalse: [ ^ self waitFor: 1000; refresh ].
	received := [self basicPoll]
		  on: Error
		  do: [ :ex |
			  self waitFor: 500.
			  self onPollFail value: ex.
			  #(  ) ].
	received do: [ :each |
		| processed |
		processed := true.
		[ self handleReceived: each ]
			on: Error
			do: [ :ex |
				processed := false.
				self onReceiveFail value: ex value: each ].
		processed ifTrue: [ self currentId: each asStreamMessageId ] ]