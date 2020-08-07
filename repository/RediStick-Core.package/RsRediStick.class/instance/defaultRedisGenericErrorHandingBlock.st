defaults
defaultRedisGenericErrorHandingBlock
	^ [:ex | 
		self logger error: ex.
		ex isNoAuth ifTrue: [ ex pass ].
	]