Class {
	#name : 'RsStreamConsumerGroupNoAckPoller',
	#superclass : 'RsStreamConsumerGroupBasePoller',
	#category : 'RediStick-Stream-Objects',
	#package : 'RediStick-Stream-Objects'
}

{ #category : 'private' }
RsStreamConsumerGroupNoAckPoller >> pollNeverDelivered [

	^ self consumer
		  neverDeliveredNoAckAtMost: self readChunkSize
		  waitFor: self waitMilliseconds
]
