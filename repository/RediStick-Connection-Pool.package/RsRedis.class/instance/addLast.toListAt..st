actions-list
addLast: value toListAt: key
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	self endpoint rPush: key value: value.
	^ value