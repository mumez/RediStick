as yet unclassified
testCreateAStickShouldAddThisToTheConnectionsDictionarry
	| connectionPoolManager stickA |
	connectionPoolManager := RsRedisConnectionPool default.
	stickA := connectionPoolManager createStrickWithKey: 'A'.
	self
		assert: (connectionPoolManager connections at: 'A')
		equals: stickA