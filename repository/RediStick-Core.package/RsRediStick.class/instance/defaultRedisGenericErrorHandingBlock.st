defaults
defaultRedisGenericErrorHandingBlock
	^ [:ex | 
		self logger error: ex.
		(ex isNoAuth or: [ ex isInvalidPassword ]) ifTrue: [ ex pass ].
	]