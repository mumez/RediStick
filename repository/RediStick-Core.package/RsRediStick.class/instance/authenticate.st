private
authenticate
	self userName ifNil: [ ^ self endpoint auth: password ].
	self endpoint auth: password user: self userName