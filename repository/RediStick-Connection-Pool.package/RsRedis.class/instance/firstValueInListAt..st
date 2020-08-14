actions-list
firstValueInListAt: key
	| col |
	key isEmptyOrNil ifTrue: [ self error: 'invalid key' ].
	col := self endpoint lRange: key start: 0 end: 0.
	col isEmptyOrNil ifTrue: [ ^ nil ].
	^ col first