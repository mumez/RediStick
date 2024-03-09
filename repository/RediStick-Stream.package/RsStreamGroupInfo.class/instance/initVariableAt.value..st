initialization
initVariableAt: key value: value
	key = 'name' ifTrue: [ ^ self name: value ].
	key = 'consumers' ifTrue: [ ^ self initConsumers: value ].
	key = 'pending' ifTrue: [ ^ self initPending: value ].
	key = 'last-delivered-id' ifTrue: [ ^ self lastDeliveredId: value ].
	key = 'entries-read' ifTrue: [ ^ self entriesRead: value ].
	key = 'lag' ifTrue: [ ^ self lag:  value ].
	key = 'pel-count' ifTrue: [ ^ self pelCount: value ].