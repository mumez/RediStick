callback
onReceiveNotAccepted
	^ onReceiveNotAccepted ifNil: [
		  onReceiveNotAccepted := [ :ex :each |
		                          self logger error: {
				                          #ReceiveNotAccepted.
				                          ex description.
				                          each asString } ] ]