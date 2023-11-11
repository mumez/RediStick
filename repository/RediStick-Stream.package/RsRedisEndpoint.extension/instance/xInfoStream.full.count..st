*RediStick-Stream
xInfoStream: key full: full count: count
	| args |
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

	^ self unifiedCommand: {
			  'XINFO'.
			  'STREAM'.
			  key }