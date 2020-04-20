private commands
unifiedCommand: args
	| received |
	received := nil.
	self sendMutex
		critical: [ self
				errorHandlingDo: [ self writeUnifiedCommand: args.
					pubsub ifFalse: [ received := self parseReply ] ].
			received ifNotNil: [ self onDataReceived: received ] ].
	^ received