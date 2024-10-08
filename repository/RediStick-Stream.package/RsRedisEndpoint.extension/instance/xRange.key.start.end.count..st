*RediStick-Stream
xRange: command key: key start: startId end: endId count: count
	| args vals |
	args := {
		        command.
		        key.
		        startId asString.
		        endId asString} asOrderedCollection.
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	vals := self unifiedCommand: args.
	^ self createStreamEntryFrom: vals