actions
releaseConnections
	connections keysAndValuesDo: [ :key :eachCol | eachCol copy do: [ :each | eachCol remove: each destroy ] ]