initialization
initVariableAt: key value: value
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'seen-time' ifTrue: [ ^ self seenTime: value ].
	key = 'active-time' ifTrue: [ ^ self activeTime: value ].
	key = 'pel-count' ifTrue: [ ^ self pelCount: value ].
	key = 'pending' ifTrue: [ ^ self initPending: value ].