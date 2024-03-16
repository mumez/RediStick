*RediStick-Stream
xInfoStream: key full: full count: count
	| args entries |
	args := {
		        'XINFO'.
		        'STREAM'.
		        key } asOrderedCollection.
	full ifTrue: [
		args add: 'FULL'.
		count ifNotNil: [
			args addAll: {
					'COUNT'.
					count } ] ].

	entries :=  self unifiedCommand: args.
	^ RsStreamInfo fromOrderedCollection: entries 