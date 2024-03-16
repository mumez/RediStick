*RediStick-Stream
xGroupSetId: key group: group id: id entriesRead: entriesRead
	| args |
	args := {
		        'XGROUP'.
		        'SETID'.
		        key.
		        group.
		        id } asOrderedCollection.
	entriesRead ifNotNil: [
		args addAll: {
				'ENTRIESREAD'.
				entriesRead } ].
	^ self unifiedCommand: args