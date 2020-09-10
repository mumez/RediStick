actions
connect
	super connect.
	self shoudAuthenticate ifTrue: [self authenticate]