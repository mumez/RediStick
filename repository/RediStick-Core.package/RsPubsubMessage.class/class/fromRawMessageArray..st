instance creation
fromRawMessageArray: messageArray
	| kind inst |
	kind := messageArray at: 1.
	inst := self new
				kind: kind;
				channel: (messageArray at: 2).
	(kind = 'subscribe' or: [ kind = 'unsubscribe' ])
		ifTrue: [ inst numberOfChannels: (messageArray at: 3)]
		ifFalse: [ inst payload: (messageArray at: 3) ].	
	^inst
	
	