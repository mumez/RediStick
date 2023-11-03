commands-stream
xRange: command key: key start: startId end: endId count: count
	| args |
	args := {
		        command.
		        key.
		        startId.
		        endId } asOrderedCollection.
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	^ self unifiedCommand: args