actions
connectionDo: aBlock at: key
	| connection |
	connection := self getConnectionAt: key.
	^ [ aBlock value: connection ]
		ensure: [ self returnConnection: connection at: key ]