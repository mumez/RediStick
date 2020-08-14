error handling
onRedisGenericErrorSignaled: aRsGenericError
	self stick isReleased ifTrue: [^self].
	self logger error: aRsGenericError.
	self stick onRedisGenericErrorSignaled: aRsGenericError