private
spawnReceiveProcess: aBlock
	"The format of messages are different for subscribe vs. psubscribe.
	Redis returns 3 elements for subcribe, 4 for psubscribe, with the
	acutal matched channel. I'm putting the matched channel last, rather
	than third, so for the client, we will always get type, channel,
	message, then finally the actual matched channel or nil."

	listener := [
	            [ self pubsub ] whileTrue: [
		            | message |
		            message := [ self parseReply ]
			                       on: RsError
			                       do: [ :ex |
				                       self socketIsConnected ifFalse: [
					                       self exitPubsub.
					                       self onErrorSignaled: ex ].
				                       nil ]. "Ignore timeout, etc"
		            message ifNotNil: [
			            self handlePubsubMessage: message callback: aBlock ] ] ]
		            forkAt: self subscriptionListenPriority