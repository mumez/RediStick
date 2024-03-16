initialization
initVariableAt: key value: value
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'pending' ifTrue: [ ^ self pending: value ].
	key = 'idle' ifTrue: [ ^ self idle: value ].
	key = 'inactive' ifTrue: [ ^ self inactive: value ]