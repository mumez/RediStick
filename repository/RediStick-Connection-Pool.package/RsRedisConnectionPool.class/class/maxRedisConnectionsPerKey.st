accessing
maxRedisConnectionsPerKey
	^maxRedisConnectionsPerKey ifNil: [ maxRedisConnectionsPerKey := 5 ]