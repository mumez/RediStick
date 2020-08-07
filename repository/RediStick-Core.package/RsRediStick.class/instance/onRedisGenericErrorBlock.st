accessing
onRedisGenericErrorBlock
	^ onRedisGenericErrorBlock ifNil: [ onRedisGenericErrorBlock := self defaultRedisGenericErrorHandingBlock]