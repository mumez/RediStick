Extension { #name : 'Object' }

{ #category : '*RediStick-Stream-Objects' }
Object >> asStreamMessageId [
	^ RsStreamMessageId fromString: self asString
]
