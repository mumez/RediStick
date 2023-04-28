actions
connectionDo: aBlock at: key
	| connection result |
	connection := self getConnectionAt: key.
	result := [ aBlock value: connection ]
		ensure: [ self returnConnection: connection at: key ].
	^ result