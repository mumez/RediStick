actions
cleanConnections
	connections keysAndValuesDo: [ :key :eachCol | self pingConnection: (self getConnectionAt: key) at: key ]