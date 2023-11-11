*RediStick-Stream
xRange: command key: key start: startId end: endId count: count
	| args vals |
	args := {
		        command.
		        key.
		        startId.
		        endId } asOrderedCollection.
	count ifNotNil: [
		args addAll: {
				'COUNT'.
				count } ].
	vals := self unifiedCommand: args.
	^ vals collect: [ :each | RsStreamEntry fromOrderedCollection: each ]