private commands
unifiedCommand: args
	"I'm sending command to the redis server with option (like pubsub) if it's activate"

	| received |
	received := nil.
	self sendMutex
		critical: [ self
				errorHandlingDo: [ self writeUnifiedCommand: args.
					pubsub
						ifFalse: [ received := self parseReply ] ].
			received ifNotNil: [ self onDataReceived: received ] ].
	^ received