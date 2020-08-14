actions
add: value toSetAt: key.
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	
	self endpoint sAdd: key member: value.
	^ value
