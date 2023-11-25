*RediStick-Stream
xGroupCreate: key group: group id: id createNotExists: createNotExists entriesRead: entriesRead
	| args |
	args := {
		        'XGROUP'.
		        'CREATE'.
		        key.
		        group.
		        id } asOrderedCollection.
	createNotExists ifTrue: [ args add: 'MKSTREAM' ].
	entriesRead ifNotNil: [
		args addAll: {
				'ENTRIESREAD'.
				entriesRead } ].
	^ self unifiedCommand: args