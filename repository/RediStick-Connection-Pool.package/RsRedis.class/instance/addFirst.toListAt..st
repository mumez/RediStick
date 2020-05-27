actions-list
addFirst: value toListAt: key
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	^ self endpoint lPush: key value: value