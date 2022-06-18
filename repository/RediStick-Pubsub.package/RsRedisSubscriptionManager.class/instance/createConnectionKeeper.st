factory
createConnectionKeeper
	| keeper |
	
	self isRunning ifTrue: [^self].
	
	keeper := [[self loopPublishPing] ensure: [self stopPublishPing]] newProcess.
	keeper priority: self connectionKeepingPriority.
	keeper name: self className, '-ConnectionKeeper'.
	^ keeper
	
