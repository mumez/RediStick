callback
onReceiveFail
	^ onReceiveFail ifNil: [
		  onReceiveFail := [ :ex :each |
		                          self logger error: {
				                          #ReceiveNotAccepted.
				                          ex description.
				                          each asString } ] ]