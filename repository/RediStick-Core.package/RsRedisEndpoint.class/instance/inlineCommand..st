private commands
inlineCommand: aCommandString
	| received |
	received := nil.
	self sendMutex
		critical: [ self
				errorHandlingDo: [ self writeString: aCommandString.
					pubsub ifFalse: [ received := self parseReply ] ].
			received ifNotNil: [ self onDataReceived: received ] ].
	^ received