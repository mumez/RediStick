factory
createEndpoint
	| ep |
	ep := super createEndpoint.
	ep remotePortNumber ifNil: [ ep remotePortNumber: 6379 ].
	^ep