actions
publishPing
	self tokenExpired ifTrue: [ 
		self resetSubscriptions
	].
	sentToken := self secondsFromUnixEpoch.
	self publish: sentToken
	