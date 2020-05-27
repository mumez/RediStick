private
getConnectionAt: key
	| matchingConnections |
	^ lock
		critical: [ matchingConnections := connections at: key ifAbsentPut: [ OrderedCollection new ].
			matchingConnections ifEmpty: [ matchingConnections add: (self newRedisConnectionAt: key) ].
			matchingConnections removeFirst ]