private
handlePubsubMessage: rawMessageArray callback: aBlock
	| message |
	message := RsPubsubMessage fromRawMessageArray: rawMessageArray.
	aBlock value: message.
	((message isUnsubscribe)and: [ message numberOfChannels = 0 ])
		ifTrue: [ self exitPubsub ]