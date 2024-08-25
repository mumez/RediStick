defaults
defaultOnRecaiveFailBlock
	^ [ :ex :each |
	  self logger error: {
			  #ReceiveNotAccepted.
			  ex description.
			  each asString } ]