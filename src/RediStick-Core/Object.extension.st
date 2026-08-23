Extension { #name : 'Object' }

{ #category : '*RediStick-Core' }
Object >> asRediStickBytesUsing: aRedisEndpoint [
	^ aRedisEndpoint utf8BytesFromString: self asString
]
