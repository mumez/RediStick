accessing
maxConnectionsPerKey
	^maxConnectionsPerKey ifNil: [maxConnectionsPerKey := self class maxRedisConnectionsPerKey]