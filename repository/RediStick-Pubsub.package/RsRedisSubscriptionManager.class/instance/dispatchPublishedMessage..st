dispatching
dispatchPublishedMessage: aMessage
	| channel payload |
	aMessage isNormal ifFalse: [ ^self ].
	payload := aMessage payload.
	channel := RsRedisPubsubChannel named: aMessage channel asSymbol.
	channel ifNil: [ ^self ].
	channel rawHandlePublished: payload
	