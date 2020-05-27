private
returnConnection: connection at: key
	lock
		critical: [ | perKeyConnections |
			perKeyConnections := connections at: key.
			perKeyConnections size >= self maxConnectionsPerKey
				ifTrue: [ connection destroy ]
				ifFalse: [ perKeyConnections add: connection ] ]