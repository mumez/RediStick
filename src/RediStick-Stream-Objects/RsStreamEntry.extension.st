Extension { #name : 'RsStreamEntry' }

{ #category : '*RediStick-Stream-Objects' }
RsStreamEntry >> asStreamMessageId [
	^ RsStreamMessageId fromString: self id
]
