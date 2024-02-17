initialization
initVariableAt: key value: value
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'consumers' ifTrue: [ ^ self consumers: value ].
	key = 'pending' ifTrue: [ ^ self pending: value ].
	key = 'last-delivered-id' ifTrue: [ ^ self lastDeliveredId: value ].
	key = 'entries-read' ifTrue: [ ^ self entriesRead: value ].
	key = 'lag' ifTrue: [ ^ self lag:  value ].