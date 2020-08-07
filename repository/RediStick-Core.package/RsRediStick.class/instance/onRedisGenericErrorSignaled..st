error handling
onRedisGenericErrorSignaled: aRsGenericError
	self onRedisGenericErrorBlock ifNotNil: [ :block | block cull: aRsGenericError cull: self]