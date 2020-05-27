actions
at: key ifAbsentPut: aBlock expiresIn: seconds
	^ (self at: key)
		ifNil: [ | return |
			return := self at: key put: aBlock value.
			self endpoint expire: key seconds: seconds.
			return ]