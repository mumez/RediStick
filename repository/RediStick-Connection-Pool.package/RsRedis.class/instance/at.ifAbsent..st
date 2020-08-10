actions
at: key ifAbsent: aBlock
	^ (self at: key) ifNil: [ aBlock value ].