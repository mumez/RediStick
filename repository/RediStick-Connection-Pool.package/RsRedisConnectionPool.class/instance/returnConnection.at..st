private
returnConnection: aRedis at: key
	lock
		critical: [ | perKeyConnections |
			perKeyConnections := connections at: key.
			perKeyConnections size >= self maxConnectionsPerKey
				ifTrue: [ aRedis destroy ]
				ifFalse: [ perKeyConnections add: aRedis ] ]