actions
at: key put: value expiresIn: seconds
	self at: key put: value.
	self  endpoint expire: key seconds: seconds.
	^value
