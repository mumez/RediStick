commands-server
slaveOf: host port: hostPort
	^ self
		unifiedCommand:
			{'SLAVEOF'.
			host.
			hostPort}