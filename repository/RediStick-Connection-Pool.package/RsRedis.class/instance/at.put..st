actions
at: key put: value
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].

	self endpoint set: key value: value.
	^value
